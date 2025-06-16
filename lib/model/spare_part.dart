class SparePart {
  final int? sparePartId;
  final String sparePartBarcode;
  final String sparePartBarcodeType;
  final String sparePartName;
  final int sparePartStock;
  final String sparePartUnit;
  final int sparePartSold;
  final int sparePartPurchasePrice;
  final int sparePartSellPrice;
  final String sparePartDateAdded;
  final String sparePartImage;

  SparePart({
    this.sparePartId,
    required this.sparePartBarcode,
    required this.sparePartBarcodeType,
    required this.sparePartName,
    required this.sparePartStock,
    required this.sparePartUnit,
    required this.sparePartSold,
    required this.sparePartPurchasePrice,
    required this.sparePartSellPrice,
    required this.sparePartDateAdded,
    required this.sparePartImage,
  });

  factory SparePart.fromJson(Map<String, dynamic> json) {
    return SparePart(
      sparePartId: json['id'],
      sparePartBarcode: json['barcode'],
      sparePartBarcodeType: json['barcodeType'],
      sparePartName: json['name'],
      sparePartStock: json['stock'],
      sparePartUnit: json['unit'],
      sparePartSold: json['sold'],
      sparePartPurchasePrice: json['purchasePrice'],
      sparePartSellPrice: json['sellPrice'],
      sparePartDateAdded: json['dateAdded'],
      sparePartImage: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': sparePartId,
      'barcode': sparePartBarcode,
      'barcodeType': sparePartBarcodeType,
      'name': sparePartName,
      'stock': sparePartStock,
      'unit': sparePartUnit,
      'sold': sparePartSold,
      'purchasePrice': sparePartPurchasePrice,
      'sellPrice': sparePartSellPrice,
      'dateAdded': sparePartDateAdded,
      'image': sparePartImage,
    };
  }

  Map<String, Object?> toMap() {
    return {
      'id': sparePartId,
      'barcode': sparePartBarcode,
      'barcodeType': sparePartBarcodeType,
      'name': sparePartName,
      'stock': sparePartStock,
      'unit': sparePartUnit,
      'sold': sparePartSold,
      'purchasePrice': sparePartPurchasePrice,
      'sellPrice': sparePartSellPrice,
      'dateAdded': sparePartDateAdded,
      'image': sparePartImage,
    };
  }
}
