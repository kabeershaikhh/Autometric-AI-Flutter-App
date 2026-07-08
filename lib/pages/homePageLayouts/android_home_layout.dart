import 'package:flutter/material.dart';

import '../../components/feature_card.dart';
import '../../components/home_app_bar.dart';
import '../../components/home_bottom_nav.dart';
import '../../components/home_drawer.dart';
import '../../components/market_card.dart';

class AndroidHomeLayout extends StatefulWidget {
  final VoidCallback onLogout;
  const AndroidHomeLayout({super.key, required this.onLogout});

  @override
  State<AndroidHomeLayout> createState() => _AndroidHomeLayoutState();
}

class _AndroidHomeLayoutState extends State<AndroidHomeLayout> {

  int selectedIndex = 0;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      key: scaffoldKey,

      backgroundColor: const Color(0xFFFDF7FF),

      ///////////////////////////////////////////////////////
      /// DRAWER
      ///////////////////////////////////////////////////////

      endDrawer: HomeDrawer(
        onLogout: () {
          Navigator.pop(context);
          widget.onLogout();

          // TODO: Logout
        },
      ),

      ///////////////////////////////////////////////////////
      /// BODY
      ///////////////////////////////////////////////////////

      body: Stack(
        children: [

          /////////////////////////////////////////////////////
          /// BACKGROUND
          /////////////////////////////////////////////////////

          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(

              padding: const EdgeInsets.all(20),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  /////////////////////////////////////////////////////
                  /// APP BAR
                  /////////////////////////////////////////////////////

                  HomeAppBar(
                    onProfileTap: () {
                      scaffoldKey.currentState!.openEndDrawer();
                    },
                  ),

                  const SizedBox(height: 28),

                  /////////////////////////////////////////////////////
                  /// MARKET CARD
                  /////////////////////////////////////////////////////

                  const MarketCard(),

                  const SizedBox(height: 28),

                  /////////////////////////////////////////////////////
                  /// SECTION TITLE
                  /////////////////////////////////////////////////////

                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  /////////////////////////////////////////////////////
                  /// FEATURE CARDS
                  /////////////////////////////////////////////////////

                  Row(
                    children: [

                      Expanded(
                        child: SizedBox(
                          height: 200,
                          child: FeatureCard(
                            icon: Icons.analytics_outlined,
                            title: "Predict Price",
                            onTap: () {},
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: SizedBox(
                          height: 200,
                          child: FeatureCard(
                            icon: Icons.car_crash_outlined,
                            title: "Damage Detection",
                            onTap: () {},
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /////////////////////////////////////////////////////
                  /// RECENT
                  /////////////////////////////////////////////////////

                  const Text(
                    "Recent Evaluations",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  recentTile(
                    "Honda Civic 2020",
                    "PKR 4,150,000",
                    Icons.directions_car,
                  ),

                  recentTile(
                    "Toyota Corolla GLi",
                    "PKR 3,450,000",
                    Icons.directions_car,
                  ),

                  recentTile(
                    "Suzuki Alto VXL",
                    "PKR 2,250,000",
                    Icons.directions_car,
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),

      ///////////////////////////////////////////////////////
      /// BOTTOM NAVIGATION
      ///////////////////////////////////////////////////////

      bottomNavigationBar: HomeBottomNav(
        currentIndex: selectedIndex,
        onTap: (index) {

          setState(() {
            selectedIndex = index;
          });

          switch (index) {

            case 0:
              break;

            case 1:
            // TODO Predict Page
              break;

            case 2:
            // TODO Damage Page
              break;

            case 3:
            // TODO History Page
              break;
          }
        },
      ),
    );
  }

  ///////////////////////////////////////////////////////
  /// RECENT TILE
  ///////////////////////////////////////////////////////

  Widget recentTile(
      String title,
      String price,
      IconData icon,
      ) {
    return Card(

      elevation: 2,

      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      child: ListTile(

        leading: CircleAvatar(
          backgroundColor: const Color(0xFF7C4DFF).withOpacity(.12),
          child: Icon(
            icon,
            color: const Color(0xFF7C4DFF),
          ),
        ),

        title: Text(title),

        subtitle: Text(price),

        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}