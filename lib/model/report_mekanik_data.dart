class ReportMekanikData {
  final int mekanikId;
  final String mekanikName;
  final int? mekanikTotalTransaction;
  final int? mekanikTotalTransactionMoney;
  final String? transactionDateRange;
  final int? selesai;
  final int? proses;
  final int? pending;
  final int? batal;
  final int transactionProfit;

  ReportMekanikData({
    required this.mekanikId,
    required this.mekanikName,
    this.mekanikTotalTransaction,
    this.mekanikTotalTransactionMoney,
    this.transactionDateRange,
    required this.transactionProfit,
    this.selesai,
    this.proses,
    this.pending,
    this.batal,
  });

  factory ReportMekanikData.fromJson(Map<String, dynamic> json) {
    return ReportMekanikData(
        mekanikId: json['mekanik_id'],
        mekanikName: json['mekanik_name'],
        mekanikTotalTransaction: json['mekanik_total_transaction'],
        mekanikTotalTransactionMoney: json['mekanik_total_transaction_money'],
        transactionDateRange: json['transaction_date_range'],
        transactionProfit: json['transaction_profit'],
        selesai: json['selesai'],
        proses: json['proses'],
        pending: json['pending'],
        batal: json['batal']);
  }

  Map<String, dynamic> toJson() {
    return {
      'mekanik_id': mekanikId,
      'mekanik_name': mekanikName,
      'mekanik_total_transaction': mekanikTotalTransaction,
      'mekanik_total_transaction_money': mekanikTotalTransactionMoney,
      'transaction_date_range': transactionDateRange,
      'transaction_profit': transactionProfit,
      'selesai': selesai,
      'proses': proses,
      'pending': pending,
      'batal': batal,
    };
  }
}
