import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/features/vehicle/vehicle_form_media_state.dart';
import 'package:auto_care/features/vehicle/vehicle_form_widgets.dart';
import 'package:auto_care/utils/media_helper.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:auto_care/widgets/auth_shell.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _vehicleNo = TextEditingController();
  final _type = TextEditingController();
  final _location = TextEditingController();
  final _ownerName = TextEditingController();
  final _ownerContact = TextEditingController();
  final _userName = TextEditingController();

  final VehicleFormMediaState _media = VehicleFormMediaState();

  @override
  void dispose() {
    _vehicleNo.dispose();
    _type.dispose();
    _location.dispose();
    _ownerName.dispose();
    _ownerContact.dispose();
    _userName.dispose();
    super.dispose();
  }

  Future<void> _captureVideo() async {
    final path = await MediaHelper.captureVideo();
    if (path == null || !mounted) return;
    setState(() => _media.videoPath = path);
  }

  Future<void> _capturePhoto() async {
    final blocked = _media.photoBlockedMessage();
    if (blocked != null) {
      showVehicleFormSnack(context, blocked);
      return;
    }
    final path = await MediaHelper.captureImage();
    if (path == null || !mounted) return;
    setState(() => _media.imagePaths.add(path));
  }

  Future<void> _uploadLicence() async {
    final blocked = _media.licenceBlockedMessage();
    if (blocked != null) {
      showVehicleFormSnack(context, blocked);
      return;
    }
    final path = await MediaHelper.pickLicenceImage(context);
    if (path == null || !mounted) return;
    setState(() => _media.licenceImagePath = path);
  }

  void _onSave() {
    Navigator.of(context).pop(
      _media.toRecord(
        vehicleNo: _vehicleNo.text.trim(),
        type: _type.text.trim(),
        location: _location.text.trim(),
        ownerName: _ownerName.text.trim(),
        ownerContact: _ownerContact.text.trim(),
        userName: _userName.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = AuthResponsive.horizontalPadding(size.width);
    final padV = AuthResponsive.verticalPadding(size.height);
    final gapLarge = AuthResponsive.gapFieldBlock(size.height);
    final scrollBottomPad = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: ColorHelper.primaryBlue,
      resizeToAvoidBottomInset: true,
      appBar: const VehicleFormAppBar(title: StringHelper.addVehicleTitle),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  padH,
                  padV,
                  padH,
                  scrollBottomPad + AuthScreenLayout.scrollBottomExtra,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: AuthResponsive.formMaxWidth(size.width),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthLoginField(
                          label: StringHelper.vehicleNoLabel,
                          hint: StringHelper.enterVehicleNo,
                          controller: _vehicleNo,
                          prefixIcon: Icons.directions_car_outlined,
                          textInputAction: TextInputAction.next,
                        ),
                        Gap(gapLarge),
                        AuthLoginField(
                          label: StringHelper.vehicleTypeLabel,
                          hint: StringHelper.enterVehicleType,
                          controller: _type,
                          prefixIcon: Icons.category_outlined,
                          textInputAction: TextInputAction.next,
                        ),
                        Gap(gapLarge),
                        AuthLoginField(
                          label: StringHelper.locationLabel,
                          hint: StringHelper.enterLocation,
                          controller: _location,
                          prefixIcon: Icons.location_on_outlined,
                          textInputAction: TextInputAction.next,
                        ),
                        Gap(gapLarge),
                        AuthLoginField(
                          label: StringHelper.ownerNameLine,
                          hint: StringHelper.enterOwnerName,
                          controller: _ownerName,
                          prefixIcon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                        ),
                        Gap(gapLarge),
                        AuthLoginField(
                          label: StringHelper.ownerContactLabel,
                          hint: StringHelper.enterOwnerContact,
                          controller: _ownerContact,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        Gap(gapLarge),
                        AuthLoginField(
                          label: StringHelper.userNameFromTableLabel,
                          hint: StringHelper.enterUserName,
                          controller: _userName,
                          prefixIcon: Icons.account_circle_outlined,
                          textInputAction: TextInputAction.done,
                        ),
                        Gap(gapLarge),
                        VehicleVideoPreview(videoPath: _media.videoPath),
                        Gap(gapLarge * 0.5),
                        VehicleMediaActionButton(
                          label: StringHelper.captureVideo,
                          onPressed: _captureVideo,
                        ),
                        Gap(gapLarge),
                        VehicleImageSlotGrid(imagePaths: _media.imagePaths),
                        Gap(gapLarge * 0.5),
                        VehicleMediaActionButton(
                          label: StringHelper.capturePhoto,
                          enabled: _media.canCapturePhoto,
                          onPressed: _capturePhoto,
                        ),
                        Gap(gapLarge),
                        VehicleLicencePreview(
                          licenceImagePath: _media.licenceImagePath,
                        ),
                        Gap(gapLarge * 0.5),
                        VehicleMediaActionButton(
                          label: StringHelper.uploadLicence,
                          enabled: _media.canUploadLicence,
                          onPressed: _uploadLicence,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            VehicleFormSaveBar(
              label: StringHelper.save,
              onPressed: _onSave,
            ),
          ],
        ),
      ),
    );
  }
}
