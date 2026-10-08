import 'package:autometric_ai/components/home_bottom_nav.dart';
import 'package:autometric_ai/components/decorated_header.dart';
import 'package:autometric_ai/components/home_drawer.dart';
import 'package:autometric_ai/components/web_page_header.dart';
import 'package:autometric_ai/components/web_sidebar.dart';
import 'package:autometric_ai/pages/app_shell.dart';
import 'package:autometric_ai/pages/settings_page.dart';
import 'package:autometric_ai/servers/user_service.dart';
import 'package:firebase_core/firebase_core.dart';
// Firebase supplies native initialization mocks through its platform package.
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _RouteObserver extends NavigatorObserver {
  int pushes = 0;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
    super.didPush(route, previousRoute);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async => Firebase.initializeApp());

  testWidgets('web header uses a white greeting or breadcrumb bar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var homeTaps = 0;
    var profileTaps = 0;
    Widget header(String section) => MaterialApp(
      home: Scaffold(
        body: WebPageHeader(
          section: section,
          userName: 'Abdul kabeer',
          photoBase64: '',
          onHome: () => homeTaps++,
          onProfile: () => profileTaps++,
        ),
      ),
    );
    await tester.pumpWidget(header('Home'));
    expect(find.text('Welcome back, Abdul kabeer! 👋'), findsOneWidget);
    expect(find.text("Let's evaluate your car today"), findsOneWidget);
    final bar = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(WebPageHeader),
            matching: find.byType(Container),
          )
          .first,
    );
    expect((bar.decoration as BoxDecoration).color, Colors.white);
    expect((bar.decoration as BoxDecoration).gradient, isNull);

    await tester.pumpWidget(header('Predict Price'));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Predict Price'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.tap(find.text('Abdul kabeer'));
    expect(homeTaps, 1);
    expect(profileTaps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings opens full screen and Back returns to prior page', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
              child: const Text('Open settings from Predict'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open settings from Predict'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
    expect(find.byType(WebSidebar), findsNothing);
    expect(find.byType(HomeBottomNav), findsNothing);
    expect(find.byType(WebPageHeader), findsNothing);
    final header = tester.widget<DecoratedHeader>(find.byType(DecoratedHeader));
    expect(header.title, 'Settings');
    expect(header.onBack, isNotNull);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Open settings from Predict'), findsOneWidget);
    expect(find.byType(SettingsPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'sidebar logout requires confirmation; guest login stays direct',
    (tester) async {
      var logouts = 0;
      var logins = 0;
      Widget sidebar({bool guest = false}) => MaterialApp(
        home: Scaffold(
          body: WebSidebar(
            selectedIndex: 0,
            onItemTap: (_) {},
            onProfileTap: () {},
            onLogout: () => logouts++,
            onLogin: () => logins++,
            isGuest: guest,
          ),
        ),
      );
      await tester.pumpWidget(sidebar());
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      expect(logouts, 0);
      expect(find.text('Log out?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(logouts, 0);
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log out'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Logging out…'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1900));
      expect(logouts, 0);
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.text('Logging out…'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(logouts, 1);
      expect(find.text('Log out?'), findsNothing);
      await tester.pumpWidget(sidebar(guest: true));
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();
      expect(logins, 1);
      expect(find.byType(Dialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'drawer cancellation keeps profile open; confirmation closes it',
    (tester) async {
      var logouts = 0;
      final scaffoldKey = GlobalKey<ScaffoldState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            key: scaffoldKey,
            endDrawer: HomeDrawer(
              onLogout: () => logouts++,
              userName: 'Abdul kabeer',
              userEmail: 'user@example.com',
              userService: UserService(),
            ),
            body: const Text('Dashboard'),
          ),
        ),
      );
      scaffoldKey.currentState!.openEndDrawer();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      expect(logouts, 0);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(logouts, 0);
      expect(scaffoldKey.currentState!.isEndDrawerOpen, isTrue);
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log out'));
      await tester.pump();
      expect(find.text('Logging out…'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1900));
      expect(logouts, 0);
      expect(scaffoldKey.currentState!.isEndDrawerOpen, isTrue);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(logouts, 1);
      expect(scaffoldKey.currentState!.isEndDrawerOpen, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('guest tab changes retain navigation and do not push routes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final observer = _RouteObserver();
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: AppShell(
          userName: 'Guest',
          userEmail: '',
          photoBase64: '',
          userService: UserService(),
          onLogout: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    final originalNav = tester.element(find.byType(HomeBottomNav));
    final initialPushes = observer.pushes;

    await tester.tap(find.text('Predict').last);
    // Let the test HTTP client return its empty options response.
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(observer.pushes, initialPushes);
    expect(tester.element(find.byType(HomeBottomNav)), same(originalNav));
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);

    final mileage = find.byType(TextFormField);
    await tester.ensureVisible(mileage);
    await tester.enterText(mileage, '45000');
    await tester.pump();

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Guest!'), findsOneWidget);
    expect(observer.pushes, initialPushes);

    await tester.tap(find.text('Predict').last);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
      '45000',
    );
    expect(observer.pushes, initialPushes);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Guest!'), findsOneWidget);

    await tester.tap(find.text('Maintenance').last);
    await tester.pumpAndSettle();
    expect(find.text('Log in to continue'), findsOneWidget);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Guest!'), findsOneWidget);
    expect(
      tester.widget<HomeBottomNav>(find.byType(HomeBottomNav)).currentIndex,
      0,
    );
    expect(tester.takeException(), isNull);
  });
}
