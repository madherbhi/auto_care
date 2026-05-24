import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/models/vehicle_record_list_model.dart';
import 'package:auto_care/features/vehicle/vehicle_form_media_state.dart';
import 'package:auto_care/features/vehicle/vehicle_form_widgets.dart';
import 'package:auto_care/utils/media_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:auto_care/utils/user_session.dart';
import 'package:auto_care/utils/vehicle_validator.dart';
import 'package:auto_care/widgets/auth_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

/// Shared vehicle form fields, validation, and media handling for add / detail.
class VehicleFormBody extends StatefulWidget {
  const VehicleFormBody({
    super.key,
    required this.formKey,
    required this.initial,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final VehicleRecord? initial;
  final ValueChanged<VehicleRecord> onSubmit;

  @override
  State<VehicleFormBody> createState() => VehicleFormBodyState();
}

class VehicleFormBodyState extends State<VehicleFormBody> {
  late final TextEditingController _vehicleNo;
  late final TextEditingController _vehicleMake;
  late final TextEditingController _vehicleModel;
  late final TextEditingController _location;
  late final TextEditingController _ownerName;
  late final TextEditingController _ownerContact;
  late final TextEditingController _userName;

  String? _segmentType;
  String? _caseType;
  late VehicleFormMediaState _media;

  @override
  void initState() {
    super.initState();
    final v = widget.initial;
    _segmentType = v?.segmentType;
    if (_segmentType != null &&
        !StringHelper.segmentTypeOptions.contains(_segmentType)) {
      _segmentType = null;
    }
    _caseType = v?.caseType;
    if (_caseType != null &&
        !StringHelper.caseTypeOptions.contains(_caseType)) {
      _caseType = null;
    }
    _vehicleNo = TextEditingController(text: v?.vehicleNo ?? '');
    _vehicleMake = TextEditingController(text: v?.vehicleMake ?? '');
    _vehicleModel = TextEditingController(text: v?.vehicleModel ?? '');
    _location = TextEditingController(text: v?.location ?? '');
    _ownerName = TextEditingController(text: v?.ownerName ?? '');
    _ownerContact = TextEditingController(text: v?.ownerContact ?? '');
    final sessionName = UserSession.userName;
    _userName = TextEditingController(
      text: v?.userName ?? sessionName ?? '',
    );
    _media = VehicleFormMediaState(
      videoPath: v?.videoPath,
      imagePaths: v?.imagePaths,
      imageMetadata: v?.imageMetadata,
      rcFrontPath: v?.rcFrontPath,
      rcBackPath: v?.rcBackPath,
    );
  }

  @override
  void dispose() {
    _vehicleNo.dispose();
    _vehicleMake.dispose();
    _vehicleModel.dispose();
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
    final capture = await MediaHelper.captureVehicleImage(
      context,
      indexNumber: _media.nextIndexNumber(),
    );
    if (capture == null || !mounted) return;
    setState(() => _media.addImage(capture));
  }

  Future<void> _uploadRcFront() async {
    final path = await MediaHelper.pickImage(context);
    if (path == null || !mounted) return;
    setState(() => _media.rcFrontPath = path);
  }

  Future<void> _uploadRcBack() async {
    final path = await MediaHelper.pickImage(context);
    if (path == null || !mounted) return;
    setState(() => _media.rcBackPath = path);
  }

  void _removeImage(int index) {
    setState(() => _media.removeImageAt(index));
  }

  void submit() {
    if (!(widget.formKey.currentState?.validate() ?? false)) return;

    if (_media.rcFrontPath == null) {
      showVehicleFormSnack(context, StringHelper.uploadRcFrontRequired);
      return;
    }
    if (_media.rcBackPath == null) {
      showVehicleFormSnack(context, StringHelper.uploadRcBackRequired);
      return;
    }

    widget.onSubmit(
      _media.toRecord(
        vehicleNo: _vehicleNo.text.trim().toUpperCase(),
        segmentType: _segmentType!,
        caseType: _caseType!,
        vehicleMake: _vehicleMake.text.trim(),
        vehicleModel: _vehicleModel.text.trim(),
        location: _location.text.trim(),
        ownerName: _ownerName.text.trim(),
        ownerContact: _ownerContact.text.replaceAll(RegExp(r'\D'), ''),
        userName: _userName.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gapLarge = AuthResponsive.gapFieldBlock(size.height);

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthLoginDropdown(
            label: StringHelper.segmentTypeLabel,
            hint: StringHelper.selectSegmentType,
            items: StringHelper.segmentTypeOptions,
            value: _segmentType,
            prefixIcon: Icons.category_outlined,
            onChanged: (v) => setState(() => _segmentType = v),
            validator: (v) => VehicleValidator.required(
              v,
              message: StringHelper.segmentTypeRequired,
            ),
          ),
          Gap(gapLarge),
          AuthLoginDropdown(
            label: StringHelper.caseTypeLabel,
            hint: StringHelper.selectCaseType,
            items: StringHelper.caseTypeOptions,
            value: _caseType,
            prefixIcon: Icons.work_outline_rounded,
            onChanged: (v) => setState(() => _caseType = v),
            validator: (v) => VehicleValidator.required(
              v,
              message: StringHelper.caseTypeRequired,
            ),
          ),
          Gap(gapLarge),
          AuthLoginField(
            label: StringHelper.vehicleNoLabel,
            hint: StringHelper.enterVehicleNo,
            controller: _vehicleNo,
            prefixIcon: Icons.directions_car_outlined,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\s\-]')),
              LengthLimitingTextInputFormatter(15),
            ],
            validator: VehicleValidator.vehicleNumber,
          ),
          Gap(gapLarge),
          AuthLoginField(
            label: StringHelper.vehicleMakeLabel,
            hint: StringHelper.enterVehicleMake,
            controller: _vehicleMake,
            prefixIcon: Icons.precision_manufacturing_outlined,
            textInputAction: TextInputAction.next,
            validator: (v) => VehicleValidator.required(
              v,
              message: StringHelper.vehicleMakeRequired,
            ),
          ),
          Gap(gapLarge),
          AuthLoginField(
            label: StringHelper.vehicleModelLabel,
            hint: StringHelper.enterVehicleModel,
            controller: _vehicleModel,
            prefixIcon: Icons.model_training_outlined,
            textInputAction: TextInputAction.next,
            validator: (v) => VehicleValidator.required(
              v,
              message: StringHelper.vehicleModelRequired,
            ),
          ),
          Gap(gapLarge),
          AuthLoginField(
            label: StringHelper.locationLabel,
            hint: StringHelper.enterLocation,
            controller: _location,
            prefixIcon: Icons.location_on_outlined,
            textInputAction: TextInputAction.next,
            validator: (v) => VehicleValidator.required(
              v,
              message: StringHelper.locationRequired,
            ),
          ),
          Gap(gapLarge),
          AuthLoginField(
            label: StringHelper.proposedOwnerNameLabel,
            hint: StringHelper.enterProposedOwnerName,
            controller: _ownerName,
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (v) => VehicleValidator.required(
              v,
              message: StringHelper.proposedOwnerNameRequired,
            ),
          ),
          Gap(gapLarge),
          AuthLoginField(
            label: StringHelper.proposedOwnerContactLabel,
            hint: StringHelper.enterProposedOwnerContact,
            controller: _ownerContact,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: VehicleValidator.contactNumber,
          ),
          Gap(gapLarge),
          AuthLoginField(
            label: StringHelper.userNameReadOnlyLabel,
            hint: StringHelper.userNameReadOnlyLabel,
            controller: _userName,
            prefixIcon: Icons.account_circle_outlined,
            readOnly: true,
          ),
          Gap(gapLarge),
          VehicleVideoPreview(
            videoPath: _media.videoPath,
            ownerContact: _ownerContact.text.trim().isEmpty
                ? null
                : _ownerContact.text.trim(),
          ),
          Gap(gapLarge * 0.5),
          VehicleMediaActionButton(
            label: StringHelper.captureVideo,
            onPressed: _captureVideo,
          ),
          Gap(gapLarge),
          const VehicleFormSectionLabel(label: StringHelper.vehicleImagesLabel),
          const Gap(8),
          VehicleImageSlotGrid(
            imagePaths: _media.imagePaths,
            onRemove: _removeImage,
            onAdd: _capturePhoto,
          ),
          Gap(gapLarge * 0.5),
          VehicleMediaActionButton(
            label: StringHelper.capturePhoto,
            onPressed: _capturePhoto,
          ),
          Gap(gapLarge),
          const VehicleFormSectionLabel(label: StringHelper.rcUploadLabel),
          const Gap(8),
          VehicleRcUploadSection(
            frontPath: _media.rcFrontPath,
            backPath: _media.rcBackPath,
            onUploadFront: _uploadRcFront,
            onUploadBack: _uploadRcBack,
          ),
        ],
      ),
    );
  }
}
