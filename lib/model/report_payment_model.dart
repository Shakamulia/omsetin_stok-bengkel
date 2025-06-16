class PaymentMethodReport {
  final int? paymentMethodId;
  final String paymentMethodName;
  final String? paymentMethodNote;
  final int totalTransactionMoney;

  PaymentMethodReport( 
      {this.paymentMethodId,
      required this.paymentMethodName,
      this.paymentMethodNote,
      required this.totalTransactionMoney});

  /// by /doc
  /// Membuat instance baru dari [PaymentMethodReport] dari objek JSON.
  ///
  /// Parameter [json] adalah map yang berisi pasangan key-value yang sesuai
  /// dengan properti dari kelas [PaymentMethodReport].
  ///
  /// Mengembalikan objek [PaymentMethodReport] dengan properti yang diisi dari data JSON.
  factory PaymentMethodReport.fromJson(Map<String, dynamic> json) {
    return PaymentMethodReport(
      paymentMethodId: json['payment_method_id'],
      paymentMethodName: json['payment_method_name'],
      paymentMethodNote: json['payment_method_note'],
      totalTransactionMoney: json['total_transaction_money'],
    );
  }

  /// by /doc
  /// Mengkonversi instance [PaymentMethodReport] ke objek JSON.
  ///
  /// Mengembalikan map yang berisi pasangan key-value yang mewakili properti
  /// dari kelas [PaymentMethodReport].
  Map<String, dynamic> toJson() {
    return {
      'payment_method_id': paymentMethodId,
      'payment_method_name': paymentMethodName,
      'payment_method_note': paymentMethodNote,
      'total_transaction_money': totalTransactionMoney,
    };
  }
}
