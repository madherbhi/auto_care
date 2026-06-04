import 'package:auto_care/features/Home/controllers/home_controller.dart';
import 'package:auto_care/starting_page.dart';
import 'package:auto_care/utils/user_session.dart';
import 'package:get/get.dart';

Future<void> logoutToStartingPage() async {
  HomeController.disposeCached();
  await UserSession.clearPersisted();
  Get.offAll(() => const StartingPage());
}
