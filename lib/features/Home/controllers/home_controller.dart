import 'package:auto_care/features/Home/models/case_model.dart';
import 'package:auto_care/features/Home/services/cases_service.dart';
import 'package:auto_care/features/vehicle/models/vehicle_record_list_model.dart';
import 'package:auto_care/utils/auth_navigation.dart';
import 'package:auto_care/utils/segment_type_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:auto_care/utils/user_session.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

enum HomeStatusTone {
  neutral,
  processing,
  submitted,
  pending,
  approved,
  rejected,
}

class HomeListRow {
  const HomeListRow({
    required this.caseId,
    required this.vehicleIcon,
    required this.registrationNumber,
    required this.ownerName,
    required this.status,
    required this.date,
    required this.statusTone,
    this.selectedCard = false,
  });

  final int caseId;
  final IconData vehicleIcon;
  final String registrationNumber;
  final String ownerName;
  final String status;
  final String date;
  final HomeStatusTone statusTone;
  final bool selectedCard;

  factory HomeListRow.fromCase(CaseModel caseModel, {bool selectedCard = false}) {
    return HomeListRow(
      caseId: caseModel.id,
      vehicleIcon: SegmentTypeHelper.iconFor(caseModel.segmentType),
      registrationNumber: caseModel.vehicleNumber,
      ownerName: caseModel.proposedOwnerName,
      status: HomeController._displayStatus(caseModel.status),
      date: HomeController._formatCreatedAt(caseModel.createdAt),
      statusTone: HomeController._statusTone(caseModel.status),
      selectedCard: selectedCard,
    );
  }
}

class HomeController extends GetxController {
  HomeController({CasesService? service})
      : _service = service ?? CasesService();

  final CasesService _service;

  final RxList<CaseModel> cases = <CaseModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadCases();
  }

  String _humanizeError(Object error) {
    final raw = error.toString().trim();
    return raw.startsWith('Exception: ') ? raw.substring(11).trim() : raw;
  }

  Future<void> loadCases() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = null;
    try {
      final token = UserSession.authToken ?? '';
      if (token.isEmpty || UserSession.isTokenExpired) {
        await _handleSessionExpired();
        return;
      }
      final username = UserSession.resolvedUserName()?.trim() ?? '';
      final fetched = await _service.fetchAllCases(
        token: token,
        username: username,
      );
      cases.assignAll(fetched);
      _sortCasesNewestFirst();
    } catch (e) {
      final message = _humanizeError(e);
      if (message == StringHelper.sessionExpired) {
        await _handleSessionExpired();
        return;
      }
      errorMessage.value = message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleSessionExpired() async {
    cases.clear();
    errorMessage.value = StringHelper.sessionExpired;
    await logoutToStartingPage();
  }

  List<HomeListRow> get filteredRows {
    final q = searchQuery.value.trim().toLowerCase();
    final source = List<CaseModel>.from(cases)..sort(_compareNewestFirst);
    final filtered = q.isEmpty
        ? source
        : source.where(
            (c) =>
                c.vehicleNumber.toLowerCase().contains(q) ||
                c.proposedOwnerName.toLowerCase().contains(q),
          );

    return filtered.map(HomeListRow.fromCase).toList();
  }

  void _sortCasesNewestFirst() {
    cases.sort(_compareNewestFirst);
  }

  static int _compareNewestFirst(CaseModel a, CaseModel b) {
    final aTime = _parseCreatedAt(a.createdAt);
    final bTime = _parseCreatedAt(b.createdAt);
    if (aTime != null && bTime != null) {
      return bTime.compareTo(aTime);
    }
    if (aTime != null) return -1;
    if (bTime != null) return 1;
    return b.id.compareTo(a.id);
  }

  static DateTime? _parseCreatedAt(String createdAt) {
    if (createdAt.isEmpty) return null;
    try {
      return DateTime.parse(createdAt).toLocal();
    } catch (_) {
      return null;
    }
  }

  CaseModel? caseForRegistration(String registrationNumber) {
    final normalized = registrationNumber.trim();
    for (final item in cases) {
      if (item.vehicleNumber == normalized) return item;
    }
    return null;
  }

  CaseModel? caseForId(int caseId) {
    for (final item in cases) {
      if (item.id == caseId) return item;
    }
    return null;
  }

  VehicleRecord vehicleForRow(HomeListRow row) {
    return caseForId(row.caseId)?.toVehicleRecord() ??
        caseForRegistration(row.registrationNumber)?.toVehicleRecord() ??
        VehicleRecord(
          vehicleNo: row.registrationNumber,
          segmentType: 'Car',
          caseType: 'Valuation',
          vehicleMake: '',
          vehicleModel: '',
          location: '',
          ownerName: row.ownerName,
          ownerContact: '',
          userName: row.ownerName,
        );
  }

  void prependCase(CaseModel caseModel) {
    cases.insert(0, caseModel);
    _sortCasesNewestFirst();
  }

  void replaceCase(CaseModel updated) {
    final index = cases.indexWhere((c) => c.id == updated.id);
    if (index >= 0) {
      cases[index] = updated.mergeMediaFrom(cases[index]);
    } else {
      cases.insert(0, updated);
    }
    _sortCasesNewestFirst();
  }

  void updateCaseFromVehicleRecord(
    String previousRegistration,
    VehicleRecord record,
  ) {
    final index = cases.indexWhere(
      (c) => c.vehicleNumber == previousRegistration.trim(),
    );
    if (index < 0) return;
    final existing = cases[index];
    cases[index] = CaseModel(
      id: existing.id,
      caseType: record.caseType,
      createdAt: existing.createdAt,
      location: record.location,
      proposedOwnerContactNo: record.ownerContact,
      proposedOwnerName: record.ownerName,
      segmentType: record.segmentType,
      status: existing.status,
      userName: record.userName,
      vehicleMake: record.vehicleMake,
      vehicleModel: record.vehicleModel,
      vehicleNumber: record.vehicleNo,
      images: existing.images,
      rcImages: existing.rcImages,
      videos: existing.videos,
    );
  }

  static String _displayStatus(String status) {
    final trimmed = status.trim();
    if (trimmed.isEmpty) return trimmed;
    final lower = trimmed.toLowerCase();
    if (lower.length == 1) return lower.toUpperCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  static HomeStatusTone _statusTone(String status) {
    final s = status.toLowerCase();
    if (s.contains('process')) return HomeStatusTone.processing;
    if (s.contains('submit')) return HomeStatusTone.submitted;
    if (s.contains('pending')) return HomeStatusTone.pending;
    if (s.contains('approv') || s == 'active') return HomeStatusTone.approved;
    if (s.contains('reject')) return HomeStatusTone.rejected;
    return HomeStatusTone.neutral;
  }

  static String _formatCreatedAt(String createdAt) {
    if (createdAt.isEmpty) return '';
    try {
      final parsed = DateTime.parse(createdAt);
      return DateFormat('dd/MM/yy').format(parsed.toLocal());
    } catch (_) {
      return createdAt;
    }
  }
}
