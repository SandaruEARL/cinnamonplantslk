import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.userId,
    required super.farmerType,
    required super.category,
    required super.amount,
    required super.description,
    required super.date,
    required super.createdAt,
  });

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      farmerType: data['farmerType'] ?? 'landOwner',
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'farmerType': farmerType,
    'category': category,
    'amount': amount,
    'description': description,
    'date': Timestamp.fromDate(date),
    'createdAt': Timestamp.fromDate(createdAt),
  };
}