class ReportSoldProduct {
  final int productId;
  final String productName;
  final String productUnit;
  final String productCategory;
  final String productImage;
  final String dateRange;
  final int productSold;

  ReportSoldProduct({
    required this.productId,
    required this.productName,
    required this.productSold,
    required this.productCategory,
    required this.dateRange,
    required this.productUnit,
    required this.productImage,
  });

  factory ReportSoldProduct.fromJson(Map<String, dynamic> json) {
    return ReportSoldProduct(
      productId: json['product_id'] as int,
      productName: json['product_name'],
      productUnit: json['product_unit'],
      productImage: json['product_image'],
      productSold: json['product_sold'],
      productCategory: json['category_name'],
      dateRange: json['date_range'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_sold': productSold,
      'category_name': productCategory,
      'date_range': dateRange,
    };
  }
}
