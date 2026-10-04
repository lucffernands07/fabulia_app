import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'home_page.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _recoverSession();

    supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _session = data.session;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _recoverSession() async {
    await Future.delayed(Duration.zero);
    if (mounted) {
      setState(() {
        _session = supabase.auth.currentSession;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF5E4),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF9EAA)),
        ),
      );
    }

    if (_session != null) {
      return const HomePage();
    }

    return const LoginPage();
  }
}
