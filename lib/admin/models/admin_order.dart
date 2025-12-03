enum OrderStatus { pending, confirmed, rejected }

class AdminOrder {
  final int id;
  final String customerName;
  final String phone;
  final String packageName;
  final String paymentStatus;
  final double amount;
  final DateTime createdAt;
  final String transferNote;
  final OrderStatus status;

  const AdminOrder({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.packageName,
    required this.paymentStatus,
    required this.amount,
    required this.createdAt,
    required this.transferNote,
    required this.status,
  });

  AdminOrder copyWith({OrderStatus? status}) {
    return AdminOrder(
      id: id,
      customerName: customerName,
      phone: phone,
      packageName: packageName,
      paymentStatus: paymentStatus,
      amount: amount,
      createdAt: createdAt,
      transferNote: transferNote,
      status: status ?? this.status,
    );
  }
}