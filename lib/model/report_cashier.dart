class ReportCashierData {
  final int cashierId;
  final String cashierName;
  final int? cashierTotalTransaction;
  final int? cashierTotalTransactionMoney;
  final String? transactionDateRange;
  final int? selesai;
  final int? proses;
  final int? pending;
  final int? batal;
  final int transactionProfit;

  ReportCashierData({
    required this.cashierId,
    required this.cashierName,
    this.cashierTotalTransaction,
    this.cashierTotalTransactionMoney,
    this.transactionDateRange,
    required this.transactionProfit,
    this.selesai,
    this.proses,
    this.pending,
    this.batal,
  });

  factory ReportCashierData.fromJson(Map<String, dynamic> json) {
    return ReportCashierData(
        cashierId: json['cashier_id'],
        cashierName: json['cashier_name'],
        cashierTotalTransaction: json['cashier_total_transaction'],
        cashierTotalTransactionMoney: json['cashier_total_transaction_money'],
        transactionDateRange: json['transaction_date_range'],
        transactionProfit: json['transaction_profit'],
        selesai: json['selesai'],
        proses: json['proses'],
        pending: json['pending'],
        batal: json['batal']);
  }

  Map<String, dynamic> toJson() {
    return {
      'cashier_id': cashierId,
      'cashier_name': cashierName,
      'cashier_total_transaction': cashierTotalTransaction,
      'cashier_total_transaction_money': cashierTotalTransactionMoney,
      'transaction_date_range': transactionDateRange,
      'transaction_profit': transactionProfit,
      'selesai': selesai,
      'proses': proses,
      'pending': pending,
      'batal': batal,
    };
  }
}
