import 'package:autometric_ai/components/responsive_shell_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final tab in [1, 2, 3]) {
    testWidgets('tab $tab and its state survive narrow/wide resizing', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final key = GlobalKey<_ShellHarnessState>();
      await tester.pumpWidget(MaterialApp(home: _ShellHarness(key: key)));
      key.currentState!.select(tab);
      await tester.pumpAndSettle();
      final pageView = tester.element(find.byType(PageView));
      final tabState = tester.state(find.byKey(ValueKey('tab-$tab')));
      await tester.tap(find.text('Page $tab: 0'));
      await tester.pump();
      for (final width in [1360.0, 800.0, 1360.0, 800.0]) {
        tester.view.physicalSize = Size(width, 900);
        await tester.pumpAndSettle();
        expect(tester.element(find.byType(PageView)), same(pageView));
        expect(tester.state(find.byKey(ValueKey('tab-$tab'))), same(tabState));
        expect(
          key.currentState!.controller.page,
          closeTo(tab.toDouble(), 0.001),
        );
        expect(find.text('Selected $tab'), findsOneWidget);
        expect(find.text('Page $tab: 1').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('resize during a tab slide still lands on the selected page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey<_ShellHarnessState>();
    await tester.pumpWidget(MaterialApp(home: _ShellHarness(key: key)));
    key.currentState!.select(2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    tester.view.physicalSize = const Size(1360, 900);
    await tester.pumpAndSettle();
    expect(key.currentState!.controller.page, closeTo(2, 0.001));
    expect(find.text('Page 2: 0').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _ShellHarness extends StatefulWidget {
  const _ShellHarness({super.key});
  @override
  State<_ShellHarness> createState() => _ShellHarnessState();
}

class _ShellHarnessState extends State<_ShellHarness> {
  final controller = PageController();
  int selected = 0;
  void select(int tab) {
    setState(() => selected = tab);
    controller.animateToPage(
      tab,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ResponsiveShellBody(
      sidebar: MediaQuery.sizeOf(context).width >= 950
          ? const SizedBox(width: 260, child: Text('Sidebar'))
          : null,
      content: Column(
        children: [
          Text('Selected $selected'),
          Expanded(
            child: PageView(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                4,
                (tab) => _TabProbe(key: ValueKey('tab-$tab'), tab: tab),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _TabProbe extends StatefulWidget {
  final int tab;
  const _TabProbe({super.key, required this.tab});
  @override
  State<_TabProbe> createState() => _TabProbeState();
}

class _TabProbeState extends State<_TabProbe>
    with AutomaticKeepAliveClientMixin {
  int count = 0;
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: TextButton(
        onPressed: () => setState(() => count++),
        child: Text('Page ${widget.tab}: $count'),
      ),
    );
  }
}
