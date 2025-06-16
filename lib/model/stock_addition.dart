class StockAdditionData {
  final int? stockAdditionId;
  final String stockAdditionName;
  final String stockAdditionDate;
  final int stockAdditionAmount;
  final String stockAdditionNote;
  final String stockAdditionProductId;

  StockAdditionData({
    this.stockAdditionId,
    required this.stockAdditionName,
    required this.stockAdditionDate,
    required this.stockAdditionAmount,
    required this.stockAdditionNote,
    required this.stockAdditionProductId,
  });

  factory StockAdditionData.fromJson(Map<String, dynamic> s) {
    return StockAdditionData(
        stockAdditionId: s['stock_addition_id'] as int,
        stockAdditionName: s['stock_addition_name'] as String,
        stockAdditionDate: s['stock_addition_date'] as dynamic,
        stockAdditionAmount: s['stock_addition_amount'] as int,
        stockAdditionNote: s['stock_addition_note'] as String,
        stockAdditionProductId: s['stock_addition_product_id'] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'stock_addition_id': stockAdditionId,
      'stock_addition_name': stockAdditionName,
      'stock_addition_date': stockAdditionDate,
      'stock_addition_amount': stockAdditionAmount,
      'stock_addition_note': stockAdditionNote,
      'stock_addition_product_id': stockAdditionProductId
    };
  }
}
