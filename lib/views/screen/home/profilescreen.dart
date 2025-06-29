import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gesturetalk1/constants/app_colors.dart';
import 'package:gesturetalk1/config/routes/app_routes.dart';
import 'package:gesturetalk1/controller/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = Supabase.instance.client.auth.currentUser;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final metadata = user?.userMetadata ?? {};
    final name = metadata['name'];
    final email = user?.email;

    final controller = Get.find<ProfileController>();
    controller.setProfile(name ?? 'Your Name', controller.imagePath.value);

    setState(() => _isLoading = false);
  }

  Future<void> _saveName(String newName) async {
    await Supabase.instance.client.auth.updateUser(
      UserAttributes(data: {'name': newName}),
    );

    // Update controller
    final controller = Get.find<ProfileController>();
    controller.setProfile(newName, controller.imagePath.value);

    Get.snackbar(
      "Updated",
      "Name updated successfully",
      backgroundColor: kPrimaryColor,
      colorText: Colors.white,
    );
  }

  Future<void> _changePassword() async {
    final newPassword = _passwordController.text.trim();
    if (newPassword.isEmpty) return;

    await Supabase.instance.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );

    Get.back();
    Get.snackbar(
      "Updated",
      "Password changed successfully",
      backgroundColor: kPrimaryColor,
      colorText: Colors.white,
    );
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final controller = Get.find<ProfileController>();
      controller.setProfile(controller.name.value, image.path);
    }
  }

  void _confirmLogout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to logout?",
      textCancel: "Cancel",
      textConfirm: "Logout",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await Supabase.instance.client.auth.signOut();
        Get.offAllNamed(AppRoutes.login);
      },
      buttonColor: Colors.red,
    );
  }

  void _showEditNameDialog() {
    final controller = Get.find<ProfileController>();
    _nameController.text = controller.name.value;
    Get.defaultDialog(
      title: "Edit Name",
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: "Enter new name"),
      ),
      textConfirm: "Save",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        final newName = _nameController.text.trim();
        if (newName.isNotEmpty) {
          _saveName(newName);
          Get.back();
        }
      },
    );
  }

  void _showChangePasswordBottomSheet() {
    _passwordController.clear();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Change Password", style: Get.textTheme.titleMedium),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                onPressed: _changePassword,
                child: const Text("Save Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: kPrimaryColor,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: GetX<ProfileController>(
                    builder: (controller) {
                      return Column(
                        children: [
                          Center(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      controller.imagePath.value != null
                                          ? FileImage(
                                            File(controller.imagePath.value!),
                                          )
                                          : null,
                                  backgroundColor: kPrimaryColor.withOpacity(
                                    0.1,
                                  ),
                                  child:
                                      controller.imagePath.value == null
                                          ? Icon(
                                            Icons.person,
                                            size: 60,
                                            color: kPrimaryColor,
                                          )
                                          : null,
                                ),
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  onPressed: _pickProfileImage,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.name.value,
                            style: theme.textTheme.titleLarge,
                          ),
                          Text(
                            user?.email ?? '',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                          ListTile(
                            leading: const Icon(Icons.edit),
                            title: const Text("Edit Name"),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: _showEditNameDialog,
                          ),
                          Divider(height: 0),
                          ListTile(
                            leading: const Icon(Icons.lock_reset),
                            title: const Text("Change Password"),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: _showChangePasswordBottomSheet,
                          ),
                          Divider(height: 0),
                          ListTile(
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            title: const Text(
                              "Logout",
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: _confirmLogout,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
    );
  }
}
