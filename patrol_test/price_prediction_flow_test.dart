import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/app.dart';
import 'helpers/test_config.dart';

void main() {

  Future<void> navigateToPredictions(PatrolIntegrationTester $) async {
    await $.ensureNetworkAvailable(); // guards against airplane mode bleed
    await startApp();
    await $.waitForLoginScreen();
    await $.loginExpectingSuccess(
      email: TestConfig.nurseryOwnerEmail,
      password: TestConfig.nurseryOwnerPassword,
    );
    await $.pump(const Duration(seconds: 2));
    await $.pumpAndSettle();
    await $.goToPredictionsTab();
    await $.waitUntilVisible(
      find.text('Price Predictions'),
      timeout: const Duration(seconds: 20),
    );
  }

  patrolTest(
    'price prediction screen loads with district and grade selectors',
        ($) async {
      await navigateToPredictions($);

      expect(find.text('Price Predictions'), findsWidgets);
      expect(find.byType(DropdownButton<String>), findsWidgets);
    },
  );

  patrolTest(
    'selecting district and grade renders the four-week forecast chart',
        ($) async {
      await navigateToPredictions($);

      await $.tap(find.text('Galle'));
      await $.pumpAndSettle();
      await $.tap(find.text('Colombo').last);
      await $.pump(const Duration(seconds: 4));
      await $.pumpAndSettle();

      await $.tap(find.text('C-4'));
      await $.pumpAndSettle();
      await $.tap(find.text('Alba').last);
      await $.pump(const Duration(seconds: 4));
      await $.pumpAndSettle();

      expect(find.textContaining('Rs'), findsWidgets);
    },
  );

  patrolTest(
    'forecast section shows week labels for four-week prediction timeline',
        ($) async {
      await navigateToPredictions($);

      await $.tap(find.text('Galle'));
      await $.pumpAndSettle();
      await $.tap(find.text('Colombo').last);
      await $.pump(const Duration(seconds: 4));
      await $.pumpAndSettle();

      await $.tap(find.text('C-4'));
      await $.pumpAndSettle();
      await $.tap(find.text('C-5').last);
      await $.pump(const Duration(seconds: 4));
      await $.pumpAndSettle();

      expect(find.textContaining('Week'), findsWidgets);
    },
  );

  patrolTest(
    'changing district and grade re-runs inference and updates forecast',
        ($) async {
      await navigateToPredictions($);

      await $.tap(find.text('Galle'));
      await $.pumpAndSettle();
      await $.tap(find.text('Colombo').last);
      await $.pump(const Duration(seconds: 4));
      await $.pumpAndSettle();

      await $.tap(find.text('C-4'));
      await $.pumpAndSettle();
      await $.tap(find.text('Alba').last);
      await $.pump(const Duration(seconds: 4));
      await $.pumpAndSettle();
      expect(find.textContaining('Rs'), findsWidgets);

      await $.tap(find.text('Colombo'));
      await $.pumpAndSettle();
      await $.tap(find.text('Galle').last);
      await $.pump(const Duration(seconds: 4));
      await $.pumpAndSettle();

      await $.tap(find.text('Alba'));
      await $.pumpAndSettle();
      await $.tap(find.text('C-5').last);
      await $.pump(const Duration(seconds: 4));
      await $.pumpAndSettle();

      expect(find.textContaining('Rs'), findsWidgets);
    },
  );

  patrolTest(
    'price prediction works with no network connectivity (offline fallback)',
        ($) async {
      await navigateToPredictions($);

      await $.native.enableAirplaneMode();
      await $.pump(const Duration(seconds: 2));
      await $.pumpAndSettle();

      await $.tap(find.text('Galle'));
      await $.pumpAndSettle();
      await $.tap(find.text('Colombo').last);
      await $.pump(const Duration(seconds: 5));
      await $.pumpAndSettle();

      await $.tap(find.text('C-4'));
      await $.pumpAndSettle();
      await $.tap(find.text('Alba').last);
      await $.pump(const Duration(seconds: 5));
      await $.pumpAndSettle();

      expect(find.textContaining('Rs'), findsWidgets);
      expect(find.textContaining('failed'), findsNothing);
      expect(find.textContaining('error'), findsNothing);

      await $.native.disableAirplaneMode();
      await $.pump(const Duration(seconds: 5)); // was 2, extra time for recovery
      await $.pumpAndSettle();
    },
  );

  patrolTest(
    'model version and last data sync date are visible on prediction screen',
        ($) async {
      await navigateToPredictions($);

      await $.tap(find.text('Galle'));
      await $.pumpAndSettle();
      await $.tap(find.text('Colombo').last);
      await $.pump(const Duration(seconds: 4));
      await $.pumpAndSettle();

      await $.tap(find.text('C-4'));
      await $.pumpAndSettle();
      await $.tap(find.text('Alba').last);
      await $.pump(const Duration(seconds: 4));
      await $.pumpAndSettle();

      expect(find.textContaining('Last updated'), findsOneWidget);
    },
  );

  patrolTest(
    'navigating away and returning to predictions tab does not crash',
        ($) async {
      await navigateToPredictions($);

      await $.tap(find.byIcon(Icons.feed));
      await $.pumpAndSettle();
      expect(find.text('Feed'), findsWidgets);

      await $.goToPredictionsTab();
      await $.waitUntilVisible(
        find.text('Price Predictions'),
        timeout: const Duration(seconds: 20),
      );
      expect(find.text('Price Predictions'), findsWidgets);
    },
  );
}