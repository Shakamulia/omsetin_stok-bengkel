class PaymentMethod {
  final int paymentMethodId;
  final String paymentMethodName;
  final String? paymentMethodNote;

  PaymentMethod(
      {required this.paymentMethodId,
      required this.paymentMethodName,
      this.paymentMethodNote});

  /// by /doc
  /// Membuat instance baru dari [PaymentMethod] dari objek JSON.
  ///
  /// Parameter [json] adalah map yang berisi pasangan key-value yang sesuai
  /// dengan properti dari kelas [PaymentMethod].
  ///
  /// Mengembalikan objek [PaymentMethod] dengan properti yang diisi dari data JSON.
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      paymentMethodId: json['payment_method_id'],
      paymentMethodName: json['payment_method_name'],
      paymentMethodNote: json['payment_method_note'],
    );
  }

  /// by /doc
  /// Mengkonversi instance [PaymentMethod] ke objek JSON.
  ///
  /// Mengembalikan map yang berisi pasangan key-value yang mewakili properti
  /// dari kelas [PaymentMethod].
  Map<String, dynamic> toJson() {
    return {
      'payment_method_id': paymentMethodId,
      'payment_method_name': paymentMethodName,
      'payment_method_note': paymentMethodNote,
    };
  }
}
