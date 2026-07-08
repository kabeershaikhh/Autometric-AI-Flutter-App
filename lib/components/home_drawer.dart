import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {

  final VoidCallback onLogout;

  const HomeDrawer({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {

    return Drawer(

      child: SafeArea(

        child: Column(

          children: [

            const SizedBox(height: 25),

            //////////////////////////////////////
            /// PROFILE IMAGE
            //////////////////////////////////////

            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFECECEC),
              child: Icon(
                Icons.person,
                size: 55,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "User Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "user@email.com",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 35),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.photo_camera),

              title: const Text("Upload Profile Picture"),

              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.edit),

              title: const Text("Change Name"),

              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.settings),

              title: const Text("Settings"),

              onTap: () {},
            ),

            const Spacer(),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),

              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),

              onTap: onLogout,
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}