import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peckpapers/features/auth/login_screen.dart';
import 'package:peckpapers/features/auth/signup_screen.dart';

void main() {
  testWidgets('Login screen renders primary actions', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('Signup screen renders fields and toggle', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });
}
