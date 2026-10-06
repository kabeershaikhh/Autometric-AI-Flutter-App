import 'package:flutter/material.dart';

import '../pages/login_page.dart';
import '../pages/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  final bool initialShowLogin;

  const LoginOrRegister({super.key, this.initialShowLogin = true});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  late bool showLoginPage;

  @override
  void initState() {
    super.initState();
    showLoginPage = widget.initialShowLogin;
  }

  // toggle
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onTap: togglePages);
    } else {
      return RegisterPage(onTap: togglePages);
    }
  }
}
