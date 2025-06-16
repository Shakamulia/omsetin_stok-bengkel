class TransactionData {
  final int transactionId;
  final String transactionDate;
  final int transactionTotal;
  final int transactionPayAmount;
  final String transactionPaymentMethod;
  final String transactionCashier;
  final String transactionCustomerName;
  final int transactionDiscount;
  final String transactionNote;
  final int transactionTax;
  final String transactionStatus;
  final int transactionQuantity;
  final List<Map<String, dynamic>> transactionProduct;
  final int transactionQueueNumber;
  final int transactionProfit;

  TransactionData(
      {required this.transactionId,
      required this.transactionDate,
      required this.transactionTotal,
      required this.transactionPayAmount,
      required this.transactionPaymentMethod,
      required this.transactionCashier,
      required this.transactionCustomerName,
      required this.transactionDiscount,
      required this.transactionNote,
      required this.transactionTax,
      required this.transactionStatus,
      required this.transactionQuantity,
      required this.transactionProduct,
      required this.transactionQueueNumber,
      required this.transactionProfit});

  factory TransactionData.fromJson(Map<String, dynamic> e) {
    return TransactionData(
      transactionId: e['transaction_id'],
      transactionDate: e['transaction_date'],
      transactionTotal: e['transaction_total'],
      transactionPayAmount: e['transaction_pay_amount'],
      transactionPaymentMethod: e['transaction_method'],
      transactionCashier: e['transaction_cashier'] ?? 'User',
      transactionCustomerName: e['transaction_customer_name'],
      transactionDiscount: e['transaction_discount'],
      transactionNote: e['transaction_note'],
      transactionTax: e['transaction_tax'],
      transactionStatus: e['transaction_status'],
      transactionQuantity: e['transaction_quantity'],
      transactionProduct: e['transaction_products'],
      transactionQueueNumber: e['transaction_queue_number'],
      transactionProfit: e['transaction_profit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'transaction_date': transactionDate,
      'transaction_total': transactionTotal,
      'transaction_pay_amount': transactionPayAmount,
      'transaction_method': transactionPaymentMethod,
      'transaction_cashier': transactionCashier,
      'transaction_customer_name': transactionCustomerName,
      'transaction_discount': transactionDiscount,
      'transaction_note': transactionNote,
      'transaction_tax': transactionTax,
      'transaction_status': transactionStatus,
      'transaction_quantity': transactionQuantity,
      'transaction_products': transactionProduct,
      'transaction_queue_number': transactionQueueNumber,
      'transaction_profit': transactionProfit
    };
  }
}
