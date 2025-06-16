import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gesturetalk1/constants/app_colors.dart';
import 'package:gesturetalk1/config/routes/app_routes.dart'; // ✅ Added for AppRoutes.login

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = Supabase.instance.client.auth.currentUser;
  final TextEditingController _nameController = TextEditingController();

  String? _email;
  String? _name;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final metadata = user?.userMetadata ?? {};
    _name = metadata['name'];
    _email = user?.email;
    if (_name != null) {
      _nameController.text = _name!;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    await Supabase.instance.client.auth.updateUser(
      UserAttributes(data: {'name': newName}),
    );
    setState(() => _name = newName);

    Get.snackbar(
      "Updated",
      "Name saved successfully",
      backgroundColor: kPrimaryColor,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_circle,
                        size: 100,
                        color: kPrimaryColor,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _email != null ? 'Email: $_email' : 'No email found',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 30),

                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Your Name',
                          hintText: 'Enter your name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                        ),
                        onPressed: _saveName,
                        icon: const Icon(Icons.save),
                        label: const Text("Save Name"),
                      ),

                      const SizedBox(height: 40),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          await Supabase.instance.client.auth.signOut();
                          Get.offAllNamed(AppRoutes.login); // ✅ Clean logout
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text("Logout"),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
