import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    isDarkMode.value = _loadThemeFromBox();
    super.onInit();
  }

  bool _loadThemeFromBox() => _box.read(_key) ?? false;
  void _saveThemeToBox(bool val) => _box.write(_key, val);

  ThemeMode get theme => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _saveThemeToBox(isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
