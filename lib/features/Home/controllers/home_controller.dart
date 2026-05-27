import 'package:auto_care/features/Home/models/case_model.dart';
import 'package:auto_care/features/Home/services/cases_service.dart';
import 'package:auto_care/features/vehicle/models/vehicle_record_list_model.dart';
import 'package:auto_care/utils/segment_type_helper.dart';
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
      final fetched = await _service.fetchAllCases(token: token);
      cases.assignAll(fetched);
    } catch (e) {
      errorMessage.value = _humanizeError(e);
    } finally {
      isLoading.value = false;
    }
  }

  List<HomeListRow> get filteredRows {
    final q = searchQuery.value.trim().toLowerCase();
    final source = cases;
    final filtered = q.isEmpty
        ? source
        : source.where(
            (c) =>
                c.vehicleNumber.toLowerCase().contains(q) ||
                c.proposedOwnerName.toLowerCase().contains(q),
          );

    return filtered.map(HomeListRow.fromCase).toList();
  }

  CaseModel? caseForRegistration(String registrationNumber) {
    final normalized = registrationNumber.trim();
    for (final item in cases) {
      if (item.vehicleNumber == normalized) return item;
    }
    return null;
  }

  VehicleRecord vehicleForRow(HomeListRow row) {
    return caseForRegistration(row.registrationNumber)?.toVehicleRecord() ??
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
