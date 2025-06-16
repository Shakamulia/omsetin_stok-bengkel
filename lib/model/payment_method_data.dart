class ReportPaymentMethodData {
  final String paymentMethodName;
  final int totalTransactionMoney;

  ReportPaymentMethodData( 
      {
      required this.paymentMethodName,
      required this.totalTransactionMoney});

  /// by /doc
  /// Membuat instance baru dari [ReportPaymentMethodData] dari objek JSON.
  ///
  /// Parameter [json] adalah map yang berisi pasangan key-value yang sesuai
  /// dengan properti dari kelas [ReportPaymentMethodData].
  ///
  /// Mengembalikan objek [ReportPaymentMethodData] dengan properti yang diisi dari data JSON.
  factory ReportPaymentMethodData.fromJson(Map<String, dynamic> json) {
    return ReportPaymentMethodData(
      paymentMethodName: json['payment_method_name'],
      totalTransactionMoney: json['total_transaction_money'],
    );
  }

  /// by /doc
  /// Mengkonversi instance [ReportPaymentMethodData] ke objek JSON.
  ///
  /// Mengembalikan map yang berisi pasangan key-value yang mewakili properti
  /// dari kelas [ReportPaymentMethodData].
  Map<String, dynamic> toJson() {
    return {
      'payment_method_name': paymentMethodName,
      'total_transaction_money': totalTransactionMoney,
    };
  }
}
