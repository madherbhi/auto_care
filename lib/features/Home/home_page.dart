import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/features/vehicle/add_vehicle_page.dart';
import 'package:auto_care/features/vehicle/vehicle_detail_page.dart';
import 'package:auto_care/models/vehicle_record_list_model.dart';
import 'package:auto_care/starting_page.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/font_helper.dart';
import 'package:auto_care/utils/navigation_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

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
    required this.vehicleIcon,
    required this.registrationNumber,
    required this.ownerName,
    required this.status,
    required this.date,
    required this.statusTone,
    this.selectedCard = false,
  });

  final IconData vehicleIcon;
  final String registrationNumber;
  final String ownerName;
  final String status;
  final String date;
  final HomeStatusTone statusTone;
  final bool selectedCard;
}

class HomeRequestListPage extends StatefulWidget {
  const HomeRequestListPage({super.key});

  @override
  State<HomeRequestListPage> createState() =>
      _HomeRequestListPageState();
}

class _HomeRequestListPageState extends State<HomeRequestListPage> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  late List<HomeListRow> _allRows = [
    const HomeListRow(
      vehicleIcon: Icons.directions_car_rounded,
      registrationNumber: "AP39FG8236",
      ownerName: "Mr. Kumar",
      status: "Submitted",
      date: "05/05/26",
      statusTone: HomeStatusTone.submitted,
      selectedCard: true,
    ),
    const HomeListRow(
      vehicleIcon: Icons.directions_car_rounded,
      registrationNumber: "AP39FG8237",
      ownerName: "Mr. Raju",
      status: "under process",
      date: "06/05/26",
      statusTone: HomeStatusTone.processing,
    ),
    const HomeListRow(
      vehicleIcon: Icons.local_shipping_rounded,
      registrationNumber: "TS10AB1234",
      ownerName: "Ms. Priya",
      status: "Pending",
      date: "04/05/26",
      statusTone: HomeStatusTone.pending,
    ),
    const HomeListRow(
      vehicleIcon: Icons.two_wheeler_rounded,
      registrationNumber: "KA05CD9999",
      ownerName: "Mr. Ahmed",
      status: "Approved",
      date: "01/05/26",
      statusTone: HomeStatusTone.approved,
    ),
    const HomeListRow(
      vehicleIcon: Icons.directions_car_rounded,
      registrationNumber: "MH12XY0001",
      ownerName: "Ms. Lee",
      status: "Rejected",
      date: "30/04/26",
      statusTone: HomeStatusTone.rejected,
    ),
  ];

  VehicleRecord _vehicleForRow(HomeListRow row) {
    return kSampleVehiclesByRegNo[row.registrationNumber] ??
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

  Future<void> _openAddVehicle() async {
    final result = await Navigator.of(context).push<VehicleRecord>(
      appRoute(const AddVehiclePage()),
    );
    if (result == null || !mounted) return;
    kSampleVehiclesByRegNo[result.vehicleNo] = result;
    setState(() {
      _allRows = [
        HomeListRow(
          vehicleIcon: Icons.directions_car_rounded,
          registrationNumber: result.vehicleNo,
          ownerName: result.ownerName,
          status: 'Pending',
          date: '13/05/26',
          statusTone: HomeStatusTone.pending,
        ),
        ..._allRows,
      ];
    });
  }

  Future<void> _openVehicleDetail(HomeListRow row) async {
    final initial = _vehicleForRow(row);
    final result = await Navigator.of(context).push<VehicleRecord>(
      appRoute(VehicleDetailPage(vehicle: initial)),
    );
    if (result == null || !mounted) return;
    kSampleVehiclesByRegNo[result.vehicleNo] = result;
    setState(() {
      _allRows = _allRows.map((r) {
        if (r.registrationNumber != row.registrationNumber) return r;
        return HomeListRow(
          vehicleIcon: r.vehicleIcon,
          registrationNumber: result.vehicleNo,
          ownerName: result.ownerName,
          status: r.status,
          date: r.date,
          statusTone: r.statusTone,
          selectedCard: r.selectedCard,
        );
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<HomeListRow> get _filteredRows {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _allRows;
    return _allRows
        .where(
          (r) =>
              r.registrationNumber.toLowerCase().contains(q) ||
              r.ownerName.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = AuthResponsive.horizontalPadding(size.width);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final rows = _filteredRows;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: ColorHelper.footerBarBg,
        appBar: const _HomeListAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HomeSearchRow(
              padH: 10,
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: (_) => setState(() {}),
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _HomeRequestCard(
                      row: rows[index],
                      onTap: () => _openVehicleDetail(rows[index]),
                    ),
                  );
                },
              ),
            ),
            _BottomActionsRow(
              padH: padH,
              bottomExtra: bottomInset * 0.2,
              onAddNew: _openAddVehicle,
              onLogout: () {
                Navigator.of(context).pushAndRemoveUntil(
                  appRoute<void>(const StartingPage()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeListAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _HomeListAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 2,
      scrolledUnderElevation: 2,
      shadowColor: ColorHelper.primaryBlue.withValues(alpha: 0.2),
      backgroundColor: ColorHelper.primaryBlue,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: const Text(
        StringHelper.inspectionRequestListTitle,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: FontHelper.poppinsSemiBold,
          color: ColorHelper.white,
          fontSize: 16,
          height: 1.2,
        ),
      ),
    );
  }
}

class _HomeSearchRow extends StatelessWidget {
  const _HomeSearchRow({
    required this.padH,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final double padH;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorHelper.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(padH, 12, padH, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontFamily: FontHelper.poppinsRegular,
                  fontSize: 14,
                  color: ColorHelper.black,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: ColorHelper.white,
                  hintText: StringHelper.inspectionSearchHint,
                  hintStyle: TextStyle(
                    fontFamily: FontHelper.poppinsRegular,
                    fontSize: 14,
                    color: ColorHelper.mediumGray.withValues(alpha: 0.85),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: ColorHelper.mediumGray.withValues(alpha: 0.9),
                    size: 22,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColorHelper.buttonOutline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColorHelper.buttonOutline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ColorHelper.primaryBlue.withValues(alpha: 0.55),
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

({Color bg, Color fg}) _statusToneColors(HomeStatusTone tone) {
  switch (tone) {
    case HomeStatusTone.processing:
      return (bg: Colors.red.shade50, fg: Colors.red.shade700);
    case HomeStatusTone.submitted:
      return (bg: Colors.blue.shade50, fg: Colors.blue.shade700);
    case HomeStatusTone.pending:
      return (bg: Colors.orange.shade50, fg: Colors.orange.shade800);
    case HomeStatusTone.approved:
      return (bg: Colors.green.shade50, fg: Colors.green.shade800);
    case HomeStatusTone.rejected:
      return (bg: ColorHelper.lightGray, fg: ColorHelper.darkGray);
    case HomeStatusTone.neutral:
      return (
        bg: ColorHelper.primaryBlue.withValues(alpha: 0.08),
        fg: ColorHelper.primaryBlue,
      );
  }
}

class _HomeRequestCard extends StatelessWidget {
  const _HomeRequestCard({required this.row, required this.onTap});

  final HomeListRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = _statusToneColors(row.statusTone);
    final showSelectedChrome = row.selectedCard &&
        row.statusTone != HomeStatusTone.submitted;
    final borderColor = showSelectedChrome
        ? ColorHelper.primaryBlue.withValues(alpha: 0.45)
        : ColorHelper.buttonOutline;
    final fill = showSelectedChrome
        ? ColorHelper.primaryBlue.withValues(alpha: 0.06)
        : ColorHelper.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: showSelectedChrome ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: ColorHelper.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorHelper.lightGray.withValues(alpha: 0.65),
                    border: Border.all(
                      color: ColorHelper.buttonOutline.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Icon(
                    row.vehicleIcon,
                    size: 26,
                    color: ColorHelper.darkGray,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.registrationNumber,
                        style: const TextStyle(
                          fontFamily: FontHelper.poppinsSemiBold,
                          fontSize: 15,
                          height: 1.2,
                          color: ColorHelper.black,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        row.ownerName,
                        style: const TextStyle(
                          fontFamily: FontHelper.poppinsRegular,
                          fontSize: 13,
                          height: 1.25,
                          color: ColorHelper.mediumGray,
                        ),
                      ),
                      const Gap(10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: tone.bg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          row.status,
                          style: TextStyle(
                            fontFamily: FontHelper.poppinsMedium,
                            fontSize: 12,
                            height: 1.2,
                            color: tone.fg,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: ColorHelper.mediumGray.withValues(alpha: 0.95),
                        ),
                        const Gap(5),
                        Text(
                          row.date,
                          style: const TextStyle(
                            fontFamily: FontHelper.poppinsRegular,
                            fontSize: 12,
                            color: ColorHelper.mediumGray,
                          ),
                        ),
                      ],
                    ),
                    const Gap(14),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: ColorHelper.buttonOutline),
                        color: ColorHelper.white,
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: ColorHelper.darkGray.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomActionsRow extends StatelessWidget {
  const _BottomActionsRow({
    required this.padH,
    required this.bottomExtra,
    required this.onAddNew,
    required this.onLogout,
  });

  final double padH;
  final double bottomExtra;
  final VoidCallback onAddNew;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Material(
      color: ColorHelper.white,
      elevation: 6,
      shadowColor: ColorHelper.black.withValues(alpha: 0.08),
      child: Padding(
        padding: EdgeInsets.fromLTRB(padH, 12, padH, 12 + bottomExtra),
        child: Row(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ColorHelper.primaryBlue,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAddNew,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: w < 360 ? 12 : 14,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            color: ColorHelper.white,
                            size: 22,
                          ),
                          Gap(8),
                          Text(
                            StringHelper.addNew,
                            style: TextStyle(
                              fontFamily: FontHelper.poppinsSemiBold,
                              fontSize: 14,
                              letterSpacing: 0.2,
                              color: ColorHelper.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Gap(w * 0.03),
            Expanded(
              child: OutlinedButton(
                onPressed: onLogout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorHelper.primaryBlue,
                  backgroundColor: ColorHelper.white,
                  side: const BorderSide(
                    color: ColorHelper.primaryBlue,
                    width: 1.5,
                  ),
                  padding: EdgeInsets.symmetric(vertical: w < 360 ? 12 : 14),
                  shape: const StadiumBorder(),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 20,
                      color: ColorHelper.primaryBlue,
                    ),
                    Gap(8),
                    Text(
                      StringHelper.logout,
                      style: TextStyle(
                        fontFamily: FontHelper.poppinsSemiBold,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
