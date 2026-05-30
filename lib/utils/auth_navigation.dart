import 'package:auto_care/starting_page.dart';
import 'package:auto_care/utils/user_session.dart';
import 'package:get/get.dart';

Future<void> logoutToStartingPage() async {
  await UserSession.clearPersisted();
  Get.offAll(() => const StartingPage());
}
