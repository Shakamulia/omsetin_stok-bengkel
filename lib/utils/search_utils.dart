List<T> filterItems<T>(
    List<T> items, String query, String Function(T) itemLabel) {
  final lowerCaseQuery = query.toLowerCase();
  return items.where((item) {
    return itemLabel(item).toLowerCase().contains(lowerCaseQuery);
  }).toList();
}
 




// contoh penggunaan:
// query dari textfield controller nya
// parameter ke satu di contoh ada itemCategories, tempatkan data array/list nya di parameter ke 1
// parameter ke dua controller textfield nya,
// parameter ke tiga untuk mengisi data nya agar bisa di gunakan oleh si function filter ini nanti,


  // void _filterCategories() {
  //   final query = _searchController.text.toLowerCase();
  //   setState(() {
  //     _filteredCategories = filterItems(itemCategories, _searchController.text, (category) => category.category);
  //   });
  // }


//! harus ada addListener di atas super.initState()


  // ** 

//* Inisialisasi _filteredProduct dengan itemProduk dan menambahkan fungsi _filterSearch sebagai listener dari _searchController
  //   _filteredProduct = itemProduk;
  //   _searchController.addListener(_filterSearch); // Fungsi ini akan dijalankan setiap kali ada perubahan pada _searchController (seperti ketika user mengetikkan sesuatu di search bar)
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   _searchController.removeListener(_filterSearch);
  //   _searchController.dispose();
  //   super.dispose();
  // }