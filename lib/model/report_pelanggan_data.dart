class ReportPelangganData {
  final int pelangganId;
  final String pelangganName;
  final int? pelangganTotalTransaction;
  final int? pelangganTotalTransactionMoney;
  final String? transactionDateRange;
  final int? selesai;
  final int? proses;
  final int? pending;
  final int? batal;
  final int transactionProfit;

  ReportPelangganData({
    required this.pelangganId,
    required this.pelangganName,
    this.pelangganTotalTransaction,
    this.pelangganTotalTransactionMoney,
    this.transactionDateRange,
    required this.transactionProfit,
    this.selesai,
    this.proses,
    this.pending,
    this.batal,
  });

  factory ReportPelangganData.fromJson(Map<String, dynamic> json) {
    return ReportPelangganData(
        pelangganId: json['pelanggan_id'],
        pelangganName: json['pelanggan_name'],
        pelangganTotalTransaction: json['pelanggan_total_transaction'],
        pelangganTotalTransactionMoney: json['pelanggan_total_transaction_money'],
        transactionDateRange: json['transaction_date_range'],
        transactionProfit: json['transaction_profit'],
        selesai: json['selesai'],
        proses: json['proses'],
        pending: json['pending'],
        batal: json['batal']);
  }

  Map<String, dynamic> toJson() {
    return {
      'pelanggan_id': pelangganId,
      'pelanggan_name': pelangganName,
      'pelanggan_total_transaction': pelangganTotalTransaction,
      'pelanggan_total_transaction_money': pelangganTotalTransactionMoney,
      'transaction_date_range': transactionDateRange,
      'transaction_profit': transactionProfit,
      'selesai': selesai,
      'proses': proses,
      'pending': pending,
      'batal': batal,
    };
  }
}
