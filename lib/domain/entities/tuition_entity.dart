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

  factory TuitionItemEntity.fromJson(Map<String, dynamic> json) {
    final statusVal = json['status'] ?? 'UNPAID';
    final amount = (json['amount'] ?? json['totalAmount'] ?? json['total_amount'] ?? 0.0) as num;
    final isPaid = statusVal == 'PAID';

    return TuitionItemEntity(
      id: json['id'] is int ? json['id'] : int.parse((json['id'] ?? 0).toString()),
      semester: json['semester'] ?? 'HK1',
      totalAmount: amount.toDouble(),
      paidAmount: isPaid ? amount.toDouble() : 0.0,
      status: statusVal,
      dueDate: json['dueDate'] ?? json['due_date'] ?? json['paidAt'] ?? '',
    );
  }
}
