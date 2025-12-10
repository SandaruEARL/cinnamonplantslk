import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.userId,
    required this. category,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      userId: json['userId'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, userId, category, amount, date];
}