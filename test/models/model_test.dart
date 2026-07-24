import 'package:cinnamonmarketplace/features/ai/data/models/price_prediction_model.dart';
import 'package:cinnamonmarketplace/features/auth/data/models/user_model.dart';
import 'package:cinnamonmarketplace/features/expense/data/models/expense_model.dart';
import 'package:cinnamonmarketplace/features/marketplace/data/models/advertisement_model.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  // ─────────────────────────────────────────────
  // UserModel Tests
  // ─────────────────────────────────────────────
  group('UserModel', () {
    test('fromFirestore maps all fields correctly', () {
      final map = {
        'name': 'Kamal Perera',
        'email': 'kamal@example.com',
        'phone': '0771234567',
        'userType': 'landOwner',
        'profilePicUrl': 'https://example.com/pic.jpg',
        'location': 'Kandy',
        'isVerified': true,
        'blockedUsers': ['uid_abc', 'uid_xyz'],
      };

      final model = UserModel.fromFirestore(map, 'user_001');

      expect(model.id, 'user_001');
      expect(model.name, 'Kamal Perera');
      expect(model.email, 'kamal@example.com');
      expect(model.phone, '0771234567');
      expect(model.userType, 'landOwner');
      expect(model.profilePicUrl, 'https://example.com/pic.jpg');
      expect(model.location, 'Kandy');
      expect(model.isVerified, true);
      expect(model.blockedUsers, ['uid_abc', 'uid_xyz']);
    });

    test('fromFirestore applies default values when fields are missing', () {
      final model = UserModel.fromFirestore({}, 'user_002');

      expect(model.id, 'user_002');
      expect(model.name, '');
      expect(model.email, '');
      expect(model.phone, '');
      expect(model.userType, '');
      expect(model.isVerified, false);
      expect(model.blockedUsers, isEmpty);
      expect(model.profilePicUrl, isNull);
      expect(model.location, isNull);
    });

    test('toFirestore returns correct map structure', () {
      final model = UserModel.fromFirestore(const {
        'name': 'Nimal Silva',
        'email': 'nimal@example.com',
        'phone': '0779876543',
        'userType': 'buyer',
        'isVerified': false,
        'blockedUsers': [],
      }, 'user_003');

      final result = model.toFirestore();

      expect(result['name'], 'Nimal Silva');
      expect(result['email'], 'nimal@example.com');
      expect(result['phone'], '0779876543');
      expect(result['userType'], 'buyer');
      expect(result['isVerified'], false);
      expect(result.containsKey('blockedUsers'), true);
    });

    test('toFirestore does not include the uid field', () {
      final model = UserModel.fromFirestore({'name': 'Test'}, 'user_004');
      final result = model.toFirestore();
      expect(result.containsKey('id'), false);
    });
  });

  // ─────────────────────────────────────────────
  // ExpenseModel Tests
  // ─────────────────────────────────────────────
  group('ExpenseModel', () {
    test('toFirestore returns correct field types', () {
      final now = DateTime(2025, 6, 15);
      final created = DateTime(2025, 6, 15, 10, 30);

      final model = ExpenseModel(
        id: 'exp_001',
        userId: 'user_001',
        farmerType: 'landOwner',
        category: 'Fertilizer',
        amount: 4500.0,
        description: 'Monthly fertilizer purchase',
        date: now,
        createdAt: created,
      );

      final result = model.toFirestore();

      expect(result['userId'], 'user_001');
      expect(result['farmerType'], 'landOwner');
      expect(result['category'], 'Fertilizer');
      expect(result['amount'], 4500.0);
      expect(result['description'], 'Monthly fertilizer purchase');
      expect(result['date'], isNotNull);
      expect(result['createdAt'], isNotNull);
    });

    test('toFirestore amount is stored as double', () {
      final model = ExpenseModel(
        id: 'exp_002',
        userId: 'user_002',
        farmerType: 'tenant',
        category: 'Labour',
        amount: 1200.50,
        description: 'Harvest labour cost',
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final result = model.toFirestore();
      expect(result['amount'], isA<double>());
      expect(result['amount'], 1200.50);
    });

    test('ExpenseModel fields are accessible from entity', () {
      final model = ExpenseModel(
        id: 'exp_003',
        userId: 'user_003',
        farmerType: 'landOwner',
        category: 'Seeds',
        amount: 800.0,
        description: 'Cinnamon seeds',
        date: DateTime(2025, 5, 1),
        createdAt: DateTime(2025, 5, 1),
      );

      expect(model.id, 'exp_003');
      expect(model.category, 'Seeds');
      expect(model.amount, 800.0);
    });
  });

  // ─────────────────────────────────────────────
  // PricePredictionModel Tests
  // ─────────────────────────────────────────────
  group('PricePredictionModel', () {
    test('fromMap parses all fields correctly', () {
      final now = DateTime(2025, 6, 20);

      final map = {
        'currentPrice': 1850.0,
        'nationalPrice': 1900.0,
        'monthlyChange': 3.5,
        'trend': 'up',
        'district': 'Kandy',
        'grade': 'Alba',
        'isWeekly': true,
        'mock': false,
        'model_version': 'v2.1',
        'model_updated_at': '2025-06-01',
        'predictions': [
          {
            'date': now,
            'average_price': 1860.0,
            'high_price': 1920.0,
            'confidence': 85.0,
            'national_average': 1910.0,
          }
        ],
      };

      final model = PricePredictionModel.fromMap(map);

      expect(model.currentPrice, 1850.0);
      expect(model.nationalPrice, 1900.0);
      expect(model.monthlyChange, 3.5);
      expect(model.trend, 'up');
      expect(model.district, 'Kandy');
      expect(model.grade, 'Alba');
      expect(model.isWeekly, true);
      expect(model.isMock, false);
      expect(model.modelVersion, 'v2.1');
      expect(model.predictions.length, 1);
    });

    test('fromMap applies default confidence of 80.0 when missing', () {
      final map = {
        'currentPrice': 1500.0,
        'monthlyChange': 1.0,
        'trend': 'stable',
        'district': 'Galle',
        'grade': 'C5',
        'isWeekly': false,
        'mock': true,
        'predictions': [
          {
            'date': DateTime(2025, 7, 1),
            'average_price': 1510.0,
            'high_price': 1550.0,
            // confidence intentionally omitted
          }
        ],
      };

      final model = PricePredictionModel.fromMap(map);
      final prediction = model.predictions.first;

      expect(prediction.confidence, 80.0);
    });

    test('fromMap sets isMock to false when mock key is absent', () {
      final map = {
        'currentPrice': 2000.0,
        'monthlyChange': 2.0,
        'trend': 'down',
        'district': 'Matale',
        'grade': 'Alba',
        'predictions': [
          {
            'date': DateTime(2025, 8, 1),
            'average_price': 1980.0,
            'high_price': 2010.0,
          }
        ],
      };

      final model = PricePredictionModel.fromMap(map);
      expect(model.isMock, false);
    });
  });

  // ─────────────────────────────────────────────
  // AdvertisementModel Tests
  // ─────────────────────────────────────────────
  group('AdvertisementModel', () {
    test('toFirestore returns all required fields', () {
      final model = AdvertisementModel(
        id: 'ad_001',
        sellerId: 'user_001',
        sellerName: 'Kamal Perera',
        sellerPhone: '0771234567',
        title: 'Alba Cinnamon Sticks',
        description: 'High quality Alba grade cinnamon',
        category: 'Cinnamon',
        price: 2500.0,
        location: 'Kandy',
        imageUrls: ['https://example.com/img1.jpg'],
        createdAt: DateTime(2025, 6, 1),
      );

      final result = model.toFirestore();

      expect(result['sellerId'], 'user_001');
      expect(result['sellerName'], 'Kamal Perera');
      expect(result['title'], 'Alba Cinnamon Sticks');
      expect(result['price'], 2500.0);
      expect(result['location'], 'Kandy');
      expect(result['imageUrls'], ['https://example.com/img1.jpg']);
      expect(result['createdAt'], isNotNull);
    });

    test('toFirestore default status is pending', () {
      final model = AdvertisementModel(
        id: 'ad_002',
        sellerId: 'user_002',
        sellerName: 'Nimal',
        sellerPhone: '0770000000',
        title: 'Test Ad',
        description: 'Test',
        category: 'Cinnamon',
        price: 1000.0,
        location: 'Colombo',
        imageUrls: [],
        createdAt: DateTime.now(),
      );

      final result = model.toFirestore();
      expect(result['status'], 'pending');
    });

    test('toFirestore default type is listing', () {
      final model = AdvertisementModel(
        id: 'ad_003',
        sellerId: 'user_003',
        sellerName: 'Saman',
        sellerPhone: '0760000000',
        title: 'Cinnamon Powder',
        description: 'Fresh ground',
        category: 'Cinnamon',
        price: 800.0,
        location: 'Galle',
        imageUrls: [],
        createdAt: DateTime.now(),
      );

      final result = model.toFirestore();
      expect(result['type'], 'listing');
    });
  });
}