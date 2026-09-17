class TuitionItemEntity {
  final int id;
  final String semester;
  final double totalAmount;
  final double paidAmount;
  final String status; // 'PAID', 'UNPAID', 'PARTIAL'
  final String dueDate;

  const TuitionItemEntity({
    required this.id,
    required this.semester,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    required this.dueDate,
  });

  double get remainingAmount => totalAmount - paidAmount;
}
