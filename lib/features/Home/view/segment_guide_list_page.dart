import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/features/Home/services/segment_guide_service.dart';
import 'package:auto_care/features/Home/view/segment_guide_video_page.dart';
import 'package:auto_care/utils/app_snackbar.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/font_helper.dart';
import 'package:auto_care/utils/segment_type_helper.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:auto_care/utils/user_session.dart';
import 'package:flutter/material.dart';

class SegmentGuideListPage extends StatefulWidget {
  const SegmentGuideListPage({super.key});

  @override
  State<SegmentGuideListPage> createState() => _SegmentGuideListPageState();
}

class _SegmentGuideListPageState extends State<SegmentGuideListPage> {
  final _service = SegmentGuideService();
  String? _loadingSegment;

  Future<void> _onSegmentTap(String displayLabel) async {
    if (_loadingSegment != null) return;

    final token = UserSession.authToken?.trim() ?? '';
    if (token.isEmpty) {
      if (!mounted) return;
      AppSnackbar.error(context, StringHelper.sessionExpired);
      return;
    }

    setState(() => _loadingSegment = displayLabel);

    try {
      final apiParam = SegmentTypeHelper.apiParamForDisplay(displayLabel);
      final guide = await _service.fetchGuide(
        segmentType: apiParam,
        token: token,
      );
      if (!mounted) return;

      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (context) => SegmentGuideVideoPage(
            videoUrl: guide.videoUrl,
            title: displayLabel,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.error(
        context,
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _loadingSegment = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padH = AuthResponsive.horizontalPadding(MediaQuery.sizeOf(context).width);

    return Scaffold(
      backgroundColor: ColorHelper.white,
      appBar: AppBar(
        backgroundColor: ColorHelper.primaryBlue,
        foregroundColor: ColorHelper.white,
        elevation: 0,
        title: const Text(
          StringHelper.segmentGuideTitle,
          style: TextStyle(
            fontFamily: FontHelper.poppinsSemiBold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(padH, 16, padH, 24),
        itemCount: StringHelper.segmentTypeOptions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final label = StringHelper.segmentTypeOptions[index];
          final isLoading = _loadingSegment == label;

          return Material(
            color: ColorHelper.white,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: isLoading ? null : () => _onSegmentTap(label),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorHelper.buttonOutline),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        SegmentTypeHelper.iconFor(label),
                        color: ColorHelper.primaryBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontFamily: FontHelper.poppinsRegular,
                            fontSize: 15,
                            color: ColorHelper.black,
                          ),
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: ColorHelper.mediumGray.withValues(alpha: 0.85),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
