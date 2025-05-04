import 'package:flutter/material.dart';
import 'package:gesturetalk1/views/screen/home/dashboardscreen.dart';
import 'package:gesturetalk1/views/screen/auth/loginscreen.dart';
import 'package:gesturetalk1/controller/auth_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final authService = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Listen for authentication state changes
    authService.authStream.listen((session) {
      setState(() {
        _isLoading = false;
      });
      if (session != null) {
        // User is authenticated, navigate to Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        // User is not authenticated, navigate to Login Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            _isLoading
                ? const CircularProgressIndicator() // Loading while checking auth state
                : const SizedBox.shrink(), // Empty box when no loading
      ),
    );
  }
}
