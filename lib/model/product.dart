class Product {
  final int productId;
  final String productBarcode;
  final String productBarcodeType;
  final String productName;
  int productStock;
  final int productSold;
  final int productPurchasePrice;
  final int productSellPrice;
  final String productDateAdded;
  final String productImage;
  String? categoryName;
  final String productUnit;

  Product copy() {
    return Product(
      productId: productId,
      productBarcode: productBarcode,
      productBarcodeType: productBarcodeType,
      productName: productName,
      productStock: productStock,
      productUnit: productUnit,
      productSold: productSold,
      productPurchasePrice: productPurchasePrice,
      productSellPrice: productSellPrice,
      productDateAdded: productDateAdded,
      productImage: productImage,
      categoryName: categoryName,
    );
  }

  static var length;

  Product(
      {required this.productId,
      required this.productBarcode,
      required this.productBarcodeType,
      required this.productName,
      required this.productStock,
      required this.productUnit,
      required this.productSold,
      required this.productPurchasePrice,
      required this.productSellPrice,
      required this.productDateAdded,
      required this.productImage,
      this.categoryName});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] as int,
      productBarcode: json['product_barcode'] as String,
      productBarcodeType: json['product_barcode_type'] as String,
      productName: json['product_name'] as String,
      productStock: json['product_stock'] as int,
      productUnit: json['product_unit'] as String,
      productSold: json['product_sold'] as int,
      productPurchasePrice: json['product_purchase_price'] as int,
      productSellPrice: json['product_sell_price'] as int,
      productDateAdded: json['product_date_added'] as String,
      productImage: json['product_image'] as String,
      categoryName: json['category_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_barcode': productBarcode,
      'product_barcode_type': productBarcodeType,
      'product_name': productName,
      'product_stock': productStock,
      'product_unit': productUnit,
      'product_sold': productSold,
      'product_purchase_price': productPurchasePrice,
      'product_sell_price': productSellPrice,
      'product_date_added': productDateAdded,
      'product_image': productImage,
      'category_name': categoryName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          productId == other.productId;

  @override
  int get hashCode => productId.hashCode;

  Map<String, Object?> toMap() {
    return {
      'product_id': productId,
      'product_barcode': productBarcode,
      'product_barcode_type': productBarcodeType,
      'product_name': productName,
      'product_stock': productStock,
      'product_unit': productUnit,
      'product_sold': productSold,
      'product_purchase_price': productPurchasePrice,
      'product_sell_price': productSellPrice,
      'product_date_added': productDateAdded,
      'product_image': productImage,
      'category_name': categoryName,
    };
  }
  // ... properti yang ada
}
