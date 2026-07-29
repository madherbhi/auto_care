import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/features/Home/models/case_model.dart';
import 'package:auto_care/features/vehicle/controllers/add_vehicle_controller.dart';
import 'package:auto_care/features/vehicle/models/vehicle_record_list_model.dart';
import 'package:auto_care/features/vehicle/widgets/vehicle_form_widgets.dart';
import 'package:auto_care/features/vehicle/widgets/vehicle_form_body.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _formBodyKey = GlobalKey<VehicleFormBodyState>();
  late final AddVehicleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AddVehicleController());
  }

  void _onSave() => _formBodyKey.currentState?.submit();

  Future<void> _onSubmit(VehicleRecord record) async {
    final created = await _controller.createCase(record);
    if (!mounted) return;

    final error = _controller.errorMessage.value;
    if (created == null) {
      if (error != null && error.isNotEmpty) {
        showVehicleFormSnack(context, error);
      }
      return;
    }

    Navigator.of(context).pop<CaseModel>(created);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = AuthResponsive.horizontalPadding(size.width);
    final padV = AuthResponsive.verticalPadding(size.height);
    final scrollBottomPad = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: ColorHelper.primaryBlue,
      resizeToAvoidBottomInset: true,
      appBar: const VehicleFormAppBar(title: StringHelper.addVehicleTitle),
      body: Stack(
        children: [
          SafeArea(
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
                    child: VehicleFormBody(
                      key: _formBodyKey,
                      formKey: _formKey,
                      initial: null,
                      onSubmit: _onSubmit,
                    ),
                  ),
                ),
              ),
                ),
                Obx(
                  () => VehicleFormSaveBar(
                    label: _controller.isSubmitting.value
                        ? StringHelper.saving
                        : StringHelper.save,
                    onPressed:
                        _controller.isSubmitting.value ? null : _onSave,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () {
              if (!_controller.isSubmitting.value) {
                return const SizedBox.shrink();
              }
              return Container(
                color: Colors.black38,
                alignment: Alignment.center,
                child: const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(StringHelper.saving),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
