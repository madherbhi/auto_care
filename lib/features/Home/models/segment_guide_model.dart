class SegmentGuideModel {
  const SegmentGuideModel({
    required this.segment,
    required this.videoUrl,
  });

  final String segment;
  final String videoUrl;

  factory SegmentGuideModel.fromJson(Map<String, dynamic> json) {
    return SegmentGuideModel(
      segment: (json['segment'] ?? '').toString().trim(),
      videoUrl: (json['videoUrl'] ?? '').toString().trim(),
    );
  }
}
