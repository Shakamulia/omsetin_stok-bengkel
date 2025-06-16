import 'dart:convert';

class TransactionData {
  final int transactionId;
  final String transactionDate;
  final int transactionTotal;
  final String transactionPaymentMethod;
  final String transactionCashier;
  final String transactionCustomerName;
  final int transactionDiscount;
  final String transactionNote;
  final int transactionTax;
  final String transactionStatus;
  final int transactionQuantity;
  final List<dynamic> transactionProduct; // Ubah jadi List<dynamic>

  TransactionData({
    required this.transactionId,
    required this.transactionDate,
    required this.transactionTotal,
    required this.transactionPaymentMethod,
    required this.transactionCashier,
    required this.transactionCustomerName,
    required this.transactionDiscount,
    required this.transactionNote,
    required this.transactionTax,
    required this.transactionStatus,
    required this.transactionQuantity,
    required this.transactionProduct, // Sesuaiin di constructor
  });

  factory TransactionData.fromJson(Map<String, dynamic> e) {
    return TransactionData(
    transactionId: e['transaction_id'] as int,
    transactionDate: e['transaction_date'] as String,
    transactionTotal: e['transaction_total'] as int,
    transactionPaymentMethod: e['transaction_method'] as String,
    transactionCashier: e['transaction_cashier'] as String,
    transactionCustomerName: e['transaction_customer_name'] as String,
    transactionDiscount: e['transaction_discount'] as int,
    transactionNote: e['transaction_note'] as String,
    transactionTax: e['transaction_tax'] as int,
    transactionStatus: e['transaction_status'] as String,
    transactionQuantity: e['transaction_quantity'] as int,
    transactionProduct: e['transaction_products'] is String
        ? jsonDecode(e['transaction_products'])
        : [], // Jika bukan String, default ke []
  );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'transaction_date': transactionDate,
      'transaction_total': transactionTotal,
      'transaction_method': transactionPaymentMethod,
      'transaction_cashier': transactionCashier ?? 'User',
      'transaction_customer_name': transactionCustomerName,
      'transaction_discount': transactionDiscount,
      'transaction_note': transactionNote,
      'transaction_tax': transactionTax,
      'transaction_status': transactionStatus,
      'transaction_quantity': transactionQuantity,
      'transaction_products': jsonEncode(transactionProduct), // Encode ke JSON String
    };
  }
}
