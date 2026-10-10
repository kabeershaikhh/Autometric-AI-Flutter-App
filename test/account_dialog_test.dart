import 'package:autometric_ai/components/account_dialog.dart';
import 'package:autometric_ai/components/decorated_header.dart';
import 'package:autometric_ai/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [360.0, 1200.0]) {
    testWidgets(
      'account dialog remains scrollable with keyboard at ${width}px',
      (tester) async {
        tester.view.physicalSize = Size(width, 700);
        tester.view.devicePixelRatio = 1;
        tester.view.viewInsets = const FakeViewPadding(bottom: 250);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AccountDialog(
                      title: 'Change Password',
                      icon: Icons.lock_outline_rounded,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final label in [
                            'Current Password',
                            'New Password',
                            'Confirm Password',
                          ]) ...[
                            TextFormField(
                              decoration: InputDecoration(labelText: label),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {},
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<DecoratedHeader>(find.byType(DecoratedHeader)).title,
          'Change Password',
        );
        await tester.ensureVisible(find.text('Cancel'));
        await tester.pumpAndSettle();
        final button = find.widgetWithText(TextButton, 'Cancel');
        final shape =
            TextButtonTheme.of(
                  tester.element(button),
                ).style!.shape!.resolve({})!
                as RoundedRectangleBorder;
        expect(shape.side.color, AppColors.primaryBorder);
        expect(shape.side.width, 1);
        expect(
          tester.getTopLeft(find.text('Save')).dy,
          lessThan(tester.getTopLeft(find.text('Cancel')).dy),
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.byType(AccountDialog), findsNothing);
      },
    );
  }
}
