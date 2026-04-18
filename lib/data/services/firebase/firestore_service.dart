import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/constants.dart';
import '../../../domain/entities/advertisement.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/entities/location.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create advertisement
  Future<String> createAdvertisement(Advertisement ad) async {
    final data = ad.toJson();
    data['status']   = 'pending';
    data['isActive'] = false;
    final docRef = await _firestore
        .collection(AppConstants.adsCollection)
        .add(data);
    return docRef.id;
  }

  // Get advertisements with pagination
  // FIXED: Reordered query to place where clauses before orderBy
  Stream<List<Advertisement>> getAdvertisements({
    String? category,
    String? location,
    int limit = 20,
  }) {
    try {
      Query query = _firestore.collection(AppConstants.adsCollection);

      query = query.where('status', isEqualTo: 'approved');

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (location != null) {
        query = query.where('location', isEqualTo: location);
      }

      // Then add orderBy
      query = query.orderBy('createdAt', descending: true);

      // Finally add limit
      query = query.limit(limit);

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return Advertisement.fromJson(data);
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to get ads: $e');
    }
  }

  // Get single advertisement
  Future<Advertisement?> getAdvertisement(String id) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.adsCollection)
          .doc(id)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return Advertisement.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get ad: $e');
    }
  }

  // Update advertisement
  Future<void> updateAdvertisement(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(AppConstants.adsCollection)
          .doc(id)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update ad: $e');
    }
  }

  // Delete advertisement
  Future<void> deleteAdvertisement(String id) async {
    try {
      await _firestore
          .collection(AppConstants.adsCollection)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete ad: $e');
    }
  }

  // Search advertisements
  Stream<List<Advertisement>> searchAdvertisements(String query) {
    try {
      return _firestore
          .collection(AppConstants.adsCollection)
          .where('status', isEqualTo: 'approved')
          .orderBy('title')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Advertisement.fromJson(data);
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to search ads: $e');
    }
  }

  // Get user's advertisements
  Stream<List<Advertisement>> getUserAdvertisements(String userId) {
    try {
      return _firestore
          .collection(AppConstants.adsCollection)
          .where('sellerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Advertisement.fromJson(data);
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to get user ads: $e');
    }
  }

  // ── LOCATIONS ──────────────────────────────────────────────

// Create or replace user's location (one per type per user)
  Future<String> saveLocation(BusinessLocation location) async {
    try {
      // Check if user already has a location of this type
      final existing = await _firestore
          .collection(AppConstants.locationsCollection)
          .where('userId', isEqualTo: location.userId)
          .where('type', isEqualTo: location.type.name)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        // Update existing
        final docId = existing.docs.first.id;
        final data = location.toJson();
        data['status'] = 'pending'; // re-review on update
        await _firestore
            .collection(AppConstants.locationsCollection)
            .doc(docId)
            .update(data);
        return docId;
      } else {
        // Create new
        final data = location.toJson();
        data['status'] = 'pending';
        final docRef = await _firestore
            .collection(AppConstants.locationsCollection)
            .add(data);
        return docRef.id;
      }
    } catch (e) {
      throw Exception('Failed to save location: $e');
    }
  }

// Get user's own locations (both types)
  Stream<List<BusinessLocation>> getUserLocations(String userId) {
    return _firestore
        .collection(AppConstants.locationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return BusinessLocation.fromJson(data);
    }).toList());
  }

// Get approved locations by type (for map display)
  Stream<List<BusinessLocation>> getApprovedLocations(LocationType type) {
    return _firestore
        .collection(AppConstants.locationsCollection)
        .where('status', isEqualTo: 'approved')
        .where('type', isEqualTo: type.name)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return BusinessLocation.fromJson(data);
    }).toList());
  }

  // Remove (unpin) a location
  Future<void> deleteLocation(String locationId) async {
    try {
      await _firestore
          .collection(AppConstants.locationsCollection)
          .doc(locationId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete location: $e');
    }
  }

  // Create expense
  Future<String> createExpense(Expense expense) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.expensesCollection)
          .add(expense.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create expense: $e');
    }
  }

  // Get user expenses
  Stream<List<Expense>> getUserExpenses(String userId) {
    try {
      return _firestore
          .collection(AppConstants.expensesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Expense.fromJson(data);
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to get expenses: $e');
    }
  }

  // Get expenses by date range
  Stream<List<Expense>> getExpensesByDateRange(
      String userId,
      DateTime startDate,
      DateTime endDate,
      ) {
    return _firestore
        .collection(AppConstants.expensesCollection)
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Expense.fromJson(data);
      }).toList();
    });
  }

  // Update expense
  Future<void> updateExpense(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(AppConstants.expensesCollection)
          .doc(id)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  // Delete expense
  Future<void> deleteExpense(String id) async {
    try {
      await _firestore
          .collection(AppConstants.expensesCollection)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  // FAVORITES

  // Add to favorites
  Future<void> addToFavorites(String userId, String adId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('favorites')
          .doc(adId)
          .set({'addedAt': DateTime.now().toIso8601String()});
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String userId, String adId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('favorites')
          .doc(adId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  // Get user favorites
  Stream<List<String>> getUserFavorites(String userId) {
    try {
      return _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('favorites')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
    } catch (e) {
      throw Exception('Failed to get favorites: $e');
    }
  }
}