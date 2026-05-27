import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/features/vehicle/models/vehicle_record_list_model.dart';
import 'package:auto_care/features/vehicle/widgets/vehicle_form_body.dart';
import 'package:auto_care/features/vehicle/widgets/vehicle_form_widgets.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:flutter/material.dart';

class VehicleDetailPage extends StatefulWidget {
  const VehicleDetailPage({super.key, required this.vehicle});

  final VehicleRecord vehicle;

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _formBodyKey = GlobalKey<VehicleFormBodyState>();

  void _onUpdate() => _formBodyKey.currentState?.submit();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = AuthResponsive.horizontalPadding(size.width);
    final padV = AuthResponsive.verticalPadding(size.height);
    final scrollBottomPad = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: ColorHelper.primaryBlue,
      resizeToAvoidBottomInset: true,
      appBar: const VehicleFormAppBar(title: StringHelper.vehicleDetailTitle),
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
                    child: VehicleFormBody(
                      key: _formBodyKey,
                      formKey: _formKey,
                      initial: widget.vehicle,
                      onSubmit: (record) =>
                          Navigator.of(context).pop(record),
                    ),
                  ),
                ),
              ),
            ),
            VehicleFormSaveBar(
              label: StringHelper.update,
              onPressed: _onUpdate,
            ),
          ],
        ),
      ),
    );
  }
}
