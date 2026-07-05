import 'package:flutter/material.dart';

import '../auth/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void logout(){
    final _authService = AuthService();
    _authService.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
            IconButton(onPressed: logout, icon: Icon(Icons.logout)
            ),
        ],
      ),

    );
  }
}
