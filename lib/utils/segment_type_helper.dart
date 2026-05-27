import 'package:auto_care/utils/string_helper.dart';
import 'package:flutter/material.dart';

class SegmentTypeHelper {
  SegmentTypeHelper._();

  static IconData iconFor(String? segmentType) {
    final normalized = segmentType?.trim() ?? '';
    if (normalized.isEmpty) return Icons.directions_car_rounded;

    for (final option in StringHelper.segmentTypeOptions) {
      if (option.toLowerCase() == normalized.toLowerCase()) {
        return _iconForOption(option);
      }
    }
    return Icons.directions_car_rounded;
  }

  static IconData _iconForOption(String option) {
    switch (option) {
      case 'Car':
        return Icons.directions_car_rounded;
      case 'Commercial vehicle':
        return Icons.local_shipping_rounded;
      case 'Construction Equipment':
        return Icons.construction_rounded;
      case 'Tractor/ harvester':
        return Icons.agriculture_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }
}
