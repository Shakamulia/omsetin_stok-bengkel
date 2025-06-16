class ProductOption {
  final String nama;
  final double harga;
  final String gambar;
  final int stok;

  ProductOption(
      {required this.nama,
      required this.harga,
      required this.gambar,
      required this.stok});
}

List<ProductOption> itemProduk = [
  ProductOption(
      stok: 5, nama: 'Produk 1', harga: 10000, gambar: "assets/sushi.jpg"),
  ProductOption(
      stok: 4,
      nama: 'ProductOption 2',
      harga: 20000,
      gambar: "assets/sushi.jpg"),
  ProductOption(
      stok: 25, nama: 'Produk 3', harga: 50000, gambar: "assets/sushi.jpg"),
];
