void sortItems<T>(
    List<T> daftarItem, Comparable Function(T) keySelector, bool urutanNaik) {
  daftarItem.sort((a, b) {
    final kunciA = keySelector(a);
    final kunciB = keySelector(b);
    if (urutanNaik) {
      return kunciA.compareTo(kunciB);
    } else {
      return kunciB.compareTo(kunciA);
    }
  });
}


//* contoh penggunaan 
//* ga cuman di pakai untuk By Sold saja!
// void _sortProductsBySold(bool highestFirst) {
//   setState(() {
//     sortItems(_filteredProduct, (produk) => produk.productSold, highestFirst);
//   });
// }
