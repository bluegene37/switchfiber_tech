import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/features/auth/screens/login_screen.dart';

Widget host(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    );

void main() {
  testWidgets('the Google button appears when the feature is enabled',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(const LoginScreen(googleEnabled: true)));
    await tester.pump();

    expect(find.text('Continue with Google'), findsOneWidget);
    // The password form must survive: Google is an additional way in, not a
    // replacement.
    expect(find.text('Sign In to Terminal'), findsOneWidget);
  });

  testWidgets('the Google button is absent when the feature is disabled',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(const LoginScreen(googleEnabled: false)));
    await tester.pump();

    expect(find.text('Continue with Google'), findsNothing);
    expect(find.text('or'), findsNothing,
        reason: 'the divider must go with the button it separates');
    expect(find.text('Sign In to Terminal'), findsOneWidget,
        reason: 'disabling Google must leave password login untouched');
  });
}
