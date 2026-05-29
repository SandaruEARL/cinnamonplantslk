import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/app.dart';
import 'helpers/test_config.dart';

void main() {
  // ── Test 1: Successful login navigates to Home ────────────────────────────────
  patrolTest(
    'valid credentials navigate to home screen',
        ($) async {
      await startApp();
      await $.waitForLoginScreen();
      expect(find.text('Welcome Back!'), findsOneWidget);

      await $.loginExpectingSuccess(
        email: TestConfig.nurseryOwnerEmail,
        password: TestConfig.nurseryOwnerPassword,
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    },
  );

  // ── Test 2: Invalid credentials stay on login ─────────────────────────────────
  patrolTest(
    'invalid credentials show error and stay on login screen',
        ($) async {
      await startApp();
      await $.waitForLoginScreen();
      expect(find.text('Welcome Back!'), findsOneWidget);

      await $.submitLoginForm(
        email: TestConfig.invalidEmail,
        password: TestConfig.invalidPassword,
      );

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
    },
  );

  // ── Test 3: Empty form shows validation errors ────────────────────────────────
  patrolTest(
    'empty login form shows inline validation errors',
        ($) async {
      await startApp();
      await $.waitForLoginScreen();
      expect(find.text('Welcome Back!'), findsOneWidget);

      await $.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await $.pumpAndSettle();

      expect(find.textContaining('required'), findsWidgets);
      expect(find.text('Welcome Back!'), findsOneWidget);
    },
  );

  // ── Test 4: Malformed email shows format error ────────────────────────────────
  patrolTest(
    'malformed email shows invalid email validation message',
        ($) async {
      await startApp();
      await $.waitForLoginScreen();

      await $.enterText(find.widgetWithHint(TextField, 'Email'), 'notanemail');
      await $.pumpAndSettle();

      await $.enterText(find.widgetWithHint(TextField, 'Password'), 'anypassword');
      await $.pumpAndSettle();

      await $.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await $.pumpAndSettle();

      // FIXED: scoped to Form to avoid matching Patrol's on-screen test label
      expect(
        find.descendant(
          of: find.byType(Form),
          matching: find.textContaining('valid email'),
        ),
        findsOneWidget,
      );
    },
  );

  // ── Test 5: Navigate to Register screen ──────────────────────────────────────
  patrolTest(
    'tapping Register navigates to registration screen',
        ($) async {
      await startApp();
      await $.waitForLoginScreen();
      expect(find.text('Welcome Back!'), findsOneWidget);

      await $.tap(find.widgetWithText(TextButton, 'Register'));
      await $.pumpAndSettle();

      // FIXED: heading + button both say "Create Account"
      expect(find.text('Create Account'), findsWidgets);
      expect(find.widgetWithHint(TextField, 'Full Name'), findsOneWidget);
      expect(find.widgetWithHint(TextField, 'Email'), findsOneWidget);
      expect(find.widgetWithHint(TextField, 'Phone Number'), findsOneWidget);
    },
  );

  // ── Test 6: Empty registration form shows validation errors ───────────────────
  patrolTest(
    'empty registration form shows validation errors',
        ($) async {
      await startApp();
      await $.waitForLoginScreen();

      await $.tap(find.widgetWithText(TextButton, 'Register'));
      await $.pumpAndSettle();

      // FIXED: heading + button both say "Create Account"
      expect(find.text('Create Account'), findsWidgets);

      await $.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await $.pumpAndSettle();

      expect(find.textContaining('required'), findsWidgets);
      expect(find.text('Create Account'), findsWidgets);
    },
  );

  // ── Test 7: Password mismatch validation ──────────────────────────────────────
  patrolTest(
    'mismatched passwords show validation error on registration',
        ($) async {
      await startApp();
      await $.waitForLoginScreen();

      await $.tap(find.widgetWithText(TextButton, 'Register'));
      await $.pumpAndSettle();

      await $.enterText(find.widgetWithHint(TextField, 'Full Name'), 'Test User');
      await $.pumpAndSettle();
      await $.enterText(find.widgetWithHint(TextField, 'Email'), 'new@test.lk');
      await $.pumpAndSettle();
      await $.enterText(find.widgetWithHint(TextField, 'Phone Number'), '0771234567');
      await $.pumpAndSettle();
      await $.enterText(find.widgetWithHint(TextField, 'Password'), 'Password@123');
      await $.pumpAndSettle();
      await $.enterText(
          find.widgetWithHint(TextField, 'Confirm Password'), 'Different@123');
      await $.pumpAndSettle();

      await $.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await $.pumpAndSettle();

      expect(find.textContaining('do not match'), findsOneWidget);
    },
  );

  // ── Test 8: Forgot Password sheet opens ──────────────────────────────────────
  patrolTest(
    'tapping Forgot Password opens the reset bottom sheet',
        ($) async {
      await startApp();
      await $.waitForLoginScreen();

      await $.tap(find.widgetWithText(TextButton, 'Forgot Password'));
      await $.pumpAndSettle();

      // FIXED: login button + bottom sheet title both say "Forgot Password"
      expect(find.text('Forgot Password'), findsWidgets);
      expect(find.text('Send Reset Link'), findsOneWidget);
    },
  );
}