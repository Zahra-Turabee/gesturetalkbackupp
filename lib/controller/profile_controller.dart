import 'package:get/get.dart';

class ProfileController extends GetxController {
  RxString name = 'Your Name'.obs;
  RxnString imagePath = RxnString();

  void setProfile(String newName, String? newImagePath) {
    name.value = newName;
    imagePath.value = newImagePath;
  }
}
