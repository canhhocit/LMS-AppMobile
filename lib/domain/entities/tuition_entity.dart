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

class PayOSPaymentEntity {
  final int invoiceId;
  final int orderCode;
  final double amount;
  final String checkoutUrl;
  final String qrCode;
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String description;
  final String status;

  const PayOSPaymentEntity({
    required this.invoiceId,
    required this.orderCode,
    required this.amount,
    required this.checkoutUrl,
    required this.qrCode,
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.description,
    required this.status,
  });

  factory PayOSPaymentEntity.fromJson(Map<String, dynamic> json) {
    return PayOSPaymentEntity(
      invoiceId: json['invoiceId'] is int ? json['invoiceId'] : int.parse((json['invoiceId'] ?? 0).toString()),
      orderCode: json['orderCode'] is int ? json['orderCode'] : int.parse((json['orderCode'] ?? 0).toString()),
      amount: ((json['amount'] ?? 0) as num).toDouble(),
      checkoutUrl: json['checkoutUrl'] ?? '',
      qrCode: json['qrCode'] ?? '',
      accountName: json['accountName'] ?? 'HOC VIEN CONG NGHE',
      accountNumber: json['accountNumber'] ?? '999920269999',
      bankName: json['bankName'] ?? 'MBBank',
      description: json['description'] ?? '',
      status: json['status'] ?? 'PENDING',
    );
  }
}
