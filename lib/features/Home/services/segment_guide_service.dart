import 'dart:convert';

import 'package:auto_care/constants/api_endpoints.dart';
import 'package:auto_care/features/Home/models/segment_guide_model.dart';
import 'package:auto_care/services/api_client.dart';
import 'package:auto_care/utils/string_helper.dart';

class SegmentGuideService {
  SegmentGuideService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<SegmentGuideModel> fetchGuide({
    required String segmentType,
    required String token,
  }) async {
    final trimmedToken = token.trim();
    if (trimmedToken.isEmpty) {
      throw Exception(StringHelper.sessionExpired);
    }

    final trimmedSegment = segmentType.trim();
    if (trimmedSegment.isEmpty) {
      throw Exception(StringHelper.segmentGuideLoadFailed);
    }

    final response = await _client.get(
      ApiEndpoints.segmentGuideBy(trimmedSegment),
      token: trimmedToken,
      endpointName: 'SEGMENT_GUIDE',
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception(StringHelper.sessionExpired);
    }

    if (response.statusCode != 200) {
      throw Exception(
        _client.apiErrorMessage(
          response.body,
          StringHelper.segmentGuideLoadFailed,
        ),
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception(StringHelper.segmentGuideLoadFailed);
    }

    final guide = SegmentGuideModel.fromJson(decoded);
    if (guide.videoUrl.isEmpty) {
      throw Exception(StringHelper.segmentGuideLoadFailed);
    }

    return guide;
  }
}
