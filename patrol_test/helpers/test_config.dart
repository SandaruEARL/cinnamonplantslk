import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

class TestConfig {
  static const String nurseryOwnerEmail    = 'test.nursery@cinnamontest.lk';
  static const String nurseryOwnerPassword = 'TestPass@123';
  static const String nurseryOwnerName     = 'Test Nursery Owner';

  static const String buyerEmail    = 'test.buyer@cinnamontest.lk';
  static const String buyerPassword = 'TestPass@123';

  static const String invalidEmail    = 'nobody@cinnamontest.lk';
  static const String invalidPassword = 'WrongPassword1';
}

extension PatrolHelpers on PatrolIntegrationTester {

  Future<void> waitForLoginScreen() async {
    await waitUntilVisible(
      find.text('Welcome Back!'),
      timeout: const Duration(seconds: 15),
    );
  }

  Future<void> loginExpectingSuccess({
    required String email,
    required String password,
  }) async {
    await _fillLoginForm(email: email, password: password);
    await waitUntilVisible(
      find.byType(BottomNavigationBar),
      timeout: const Duration(seconds: 30),
    );
    await pump(const Duration(seconds: 1));
    await pumpAndSettle();
  }

  Future<void> submitLoginForm({
    required String email,
    required String password,
  }) async {
    await _fillLoginForm(email: email, password: password);
    await pump(const Duration(seconds: 3));
    await pumpAndSettle();
  }

  Future<void> _fillLoginForm({
    required String email,
    required String password,
  }) async {
    await enterText(find.widgetWithHint(TextField, 'Email'), email);
    await pumpAndSettle();
    await enterText(find.widgetWithHint(TextField, 'Password'), password);
    await pumpAndSettle();
    await tap(find.widgetWithText(ElevatedButton, 'Login'));
  }

  Future<void> goToPredictionsTab() async {
    await tap(find.byWidgetPredicate(
          (w) => w is FaIcon && w.icon == FontAwesomeIcons.chartLine,
    ));
    await pump(const Duration(seconds: 3));
    await pumpAndSettle();
  }

  /// Call at the start of any test that follows an airplane-mode test.
  /// Silently disables airplane mode if it was left on by a previous test.
  Future<void> ensureNetworkAvailable() async {
    try {
      await native.disableAirplaneMode();
      await pump(const Duration(seconds: 5));
      await pumpAndSettle();
    } catch (_) {
      // Already off — nothing to do
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await enterText(find.widgetWithHint(TextField, 'Full Name'), name);
    await pumpAndSettle();
    await enterText(find.widgetWithHint(TextField, 'Email'), email);
    await pumpAndSettle();
    await enterText(find.widgetWithHint(TextField, 'Phone Number'), phone);
    await pumpAndSettle();
    await enterText(find.widgetWithHint(TextField, 'Password'), password);
    await pumpAndSettle();
    await enterText(find.widgetWithHint(TextField, 'Confirm Password'), password);
    await pumpAndSettle();
    await tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await pump(const Duration(seconds: 4));
    await pumpAndSettle();
  }
}

extension FinderExtensions on CommonFinders {
  Finder widgetWithHint(Type type, String hint) {
    return byWidgetPredicate((widget) {
      if (widget is TextField) {
        return widget.decoration?.hintText == hint;
      }
      return false;
    });
  }
}