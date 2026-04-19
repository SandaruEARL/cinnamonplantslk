class ExpenseEntity {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  const ExpenseEntity({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
  });
}