import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gesturetalk1/views/screen/home/dashboardscreen.dart';
import 'package:gesturetalk1/views/screen/auth/loginscreen.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}
