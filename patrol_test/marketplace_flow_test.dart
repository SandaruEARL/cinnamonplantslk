import 'package:cinnamonmarketplace/features/marketplace/presentation/widgets/anouncement_card.dart';
import 'package:cinnamonmarketplace/features/marketplace/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/app.dart';
import 'helpers/test_config.dart';

void main() {

  Future<void> loginAndGoToMarketplace(PatrolIntegrationTester $) async {
    await startApp();
    await $.waitForLoginScreen();
    await $.loginExpectingSuccess(
      email: TestConfig.nurseryOwnerEmail,
      password: TestConfig.nurseryOwnerPassword,
    );
    await $.pump(const Duration(seconds: 2));
    await $.pumpAndSettle();
    await $.waitUntilVisible(find.byType(BottomNavigationBar));
  }

  patrolTest(
    'marketplace feed renders listings after authentication',
        ($) async {
      await loginAndGoToMarketplace($);

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Listings'), findsOneWidget);
      expect(find.text('Announcements'), findsOneWidget);

      await $.pump(const Duration(seconds: 3));
      await $.pumpAndSettle();
      expect(find.byType(ProductCard), findsWidgets);
    },
  );

  patrolTest(
    'listings tab is selected by default on marketplace screen',
        ($) async {
      await loginAndGoToMarketplace($);

      await $.pump(const Duration(seconds: 3));
      await $.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    },
  );

  patrolTest(
    'tapping Announcements tab switches tab content',
        ($) async {
      await loginAndGoToMarketplace($);

      await $.tap(find.text('Announcements'));
      await $.pump(const Duration(seconds: 3));
      await $.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);

      final hasAnnouncements =
          find.byType(AnnouncementCard).evaluate().isNotEmpty;
      final hasEmptyStateText =
          find.text('No buying announcements yet').evaluate().isNotEmpty;
      expect(hasAnnouncements || hasEmptyStateText, isTrue);
    },
  );

  patrolTest(
    'tapping a product card navigates to listing detail screen',
        ($) async {
      await loginAndGoToMarketplace($);

      await $.pump(const Duration(seconds: 3));
      await $.pumpAndSettle();

      final cards = find.byType(ProductCard);
      expect(cards, findsWidgets);

      await $.tap(cards.first);
      await $.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);

      await $.tap(find.byType(BackButton));
      await $.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    },
  );

  patrolTest(
    'authenticated user tapping FAB opens post type bottom sheet',
        ($) async {
      await loginAndGoToMarketplace($);

      await $.tap(find.byType(FloatingActionButton));
      await $.pumpAndSettle();

      expect(find.text('Create a post'), findsOneWidget);
      expect(find.text('Listing'), findsOneWidget);
      expect(find.text('Buying announcement'), findsOneWidget);
    },
  );

  patrolTest(
    'unauthenticated user is presented with login screen on launch',
        ($) async {
      await startApp();
      await $.waitForLoginScreen();

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
    },
  );

  patrolTest(
    'bottom navigation switches between Feed Chat Predictions and Tools tabs',
        ($) async {
      await loginAndGoToMarketplace($);

      await $.tap(find.byIcon(Icons.chat));
      await $.pumpAndSettle();
      expect(find.text('Chat'), findsWidgets);

      await $.goToPredictionsTab();
      await $.waitUntilVisible(
        find.text('Price Predictions'),
        timeout: const Duration(seconds: 20),
      );
      expect(find.text('Price Predictions'), findsOneWidget);

      await $.tap(find.byIcon(Icons.apps));
      await $.pumpAndSettle();
      expect(find.text('Tools'), findsWidgets);

      await $.tap(find.byIcon(Icons.feed));
      await $.pumpAndSettle();
      expect(find.text('Feed'), findsWidgets);
    },
  );

  patrolTest(
    'search field is present on listings tab',
        ($) async {
      await loginAndGoToMarketplace($);

      await $.pump(const Duration(seconds: 2));
      await $.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      await $.enterText(find.byType(TextField), 'Alba');
      await $.pumpAndSettle();
    },
  );
}