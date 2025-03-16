class Transaction {
  const Transaction({
    required this.id,
    required this.date,
    required this.amount
  });

  final String id;
  final String date;
  final double amount;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      date: json['date'],
      amount: json['amount']
    );
  }
}
