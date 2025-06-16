class CashierData {
  final int cashierId;
  final String cashierName;
  final int cashierPhoneNumber;
  final String cashierImage;
  final int cashierPin;
  final int? cashierTotalTransaction;
  final int? cashierTotalTransactionMoney;
  final String? transactionDateRange;
  final int? selesai;
  final int? proses;
  final int? pending;
  final int? batal;

  CashierData({
    required this.cashierId,
    required this.cashierName,
    required this.cashierPhoneNumber,
    required this.cashierImage,
    this.cashierTotalTransaction,
    this.cashierTotalTransactionMoney,
    this.transactionDateRange,
    required this.cashierPin,
    this.selesai,
    this.proses,
    this.pending,
    this.batal,
  });

  factory CashierData.fromJson(Map<String, dynamic> json) {
    return CashierData(
        cashierId: json['cashier_id'],
        cashierName: json['cashier_name'],
        cashierPhoneNumber: json['cashier_phone_number'],
        cashierImage: json['cashier_image'],
        cashierTotalTransaction: json['cashier_total_transaction'],
        cashierTotalTransactionMoney: json['cashier_total_transaction_money'],
        transactionDateRange: json['transaction_date_range'],
        cashierPin: json['cashier_pin'],
        selesai: json['selesai'],
        proses: json['proses'],
        pending: json['pending'],
        batal: json['batal']);
  }

  Map<String, dynamic> toJson() {
    return {
      'cashier_id': cashierId,
      'cashier_name': cashierName,
      'cashier_phone_number': cashierPhoneNumber,
      'cashier_image': cashierImage,
      'cashier_total_transaction': cashierTotalTransaction,
      'cashier_total_transaction_money': cashierTotalTransactionMoney,
      'transaction_date_range': transactionDateRange,
      'cashier_pin': cashierPin,
      'selesai': selesai,
      'proses': proses,
      'pending': pending,
      'batal': batal,
    };
  }
}
