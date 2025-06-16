class QRCode {
  final String type;
  final String text;
  final String image;

  QRCode({required this.image, required this.type, required this.text});
}

final List<QRCode> itemQRCode = [
  QRCode(type: 'barcode', text: 'Barcode Saja', image: "assets/qr/barcode.png"),
  QRCode(
      type: 'barcodeNama',
      text: 'Barcode + Nama',
      image: "assets/qr/barcodeNama.png"),
  QRCode(
      type: 'barcodeHarga',
      text: 'Barcode + Harga',
      image: "assets/qr/barcodeHarga.png"),
  QRCode(
      type: 'BarcodeNamaHarga',
      text: 'Barcode + Nama & Harga',
      image: "assets/qr/barcodeHargaNama.png"),
  QRCode(type: 'qrcode', text: 'Qrcode Saja', image: "assets/qr/qrcode.png"),
  QRCode(
      type: 'qrcodeNama',
      text: 'Qrcode + Nama',
      image: "assets/qr/qrcodeNama.png"),
  QRCode(
      type: 'qrcodeHarga',
      text: 'Qrcode + Harga',
      image: "assets/qr/qrcodeHarga.png"),
  QRCode(
      type: 'qrcodeNamaHarga',
      text: 'Qrcode + Nama & Harga',
      image: "assets/qr/qrcodeHargaNama.png"),
];
