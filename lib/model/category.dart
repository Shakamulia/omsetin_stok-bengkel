class Categories {
  final int categoryId;
  final String categoryName;
  final String dateAdded;

  Categories(
      {required this.dateAdded,
      required this.categoryName,
      required this.categoryId});

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      dateAdded: json['category_date_added'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'category_date_added': dateAdded
    };
  }
}

// List<Categories> itemCategories = [
//   Categories(
//     categoryId: 1,
//     categoryName: "Makanan",
//     dateAdded: DateTime(2021, 3, 14).toIso8601String(),
//   ),
//   Categories(
//     categoryId: 2,
//     categoryName: "Minuman",
//     dateAdded: DateTime(2022, 6, 19).toIso8601String(),
//   ),
//   Categories(
//     categoryId: 3,
//     categoryName: "Kebutuhan Rumah Tangga",
//     dateAdded: DateTime(2020, 1, 25).toIso8601String(),
//   ),
//   Categories(
//     categoryId: 4,
//     categoryName: "Peralatan",
//     dateAdded: DateTime(2021, 9, 8).toIso8601String(),
//   ),
//   Categories(
//     categoryId: 5,
//     categoryName: "Bahan Bangunan",
//     dateAdded: DateTime(2019, 12, 5).toIso8601String(),
//   ),
//   Categories(
//     categoryId: 6,
//     categoryName: "Elektronik",
//     dateAdded: DateTime(2023, 2, 17).toIso8601String(),
//   ),
//   Categories(
//     categoryId: 7,
//     categoryName: "Fashion",
//     dateAdded: DateTime(2020, 11, 22).toIso8601String(),
//   ),
//   Categories(
//     categoryId: 8,
//     categoryName: "Kesehatan",
//     dateAdded: DateTime(2022, 5, 3).toIso8601String(),
//   ),
//   Categories(
//     categoryId: 9,
//     categoryName: "Olahraga",
//     dateAdded: DateTime(2021, 7, 10).toIso8601String(),
//   ),
//   Categories(
//     categoryId: 10,
//     categoryName: "Pendidikan",
//     dateAdded: DateTime(2023, 4, 1).toIso8601String(),
//   ),
//   Categories(
//     categoryId: 11,
//     categoryName: "Perawatan Tubuh",
//     dateAdded: DateTime(2019, 8, 14).toIso8601String(),
//   ),
//   Categories(
//     categoryId: 12,
//     categoryName: "Perkakas",
//     dateAdded: DateTime(2020, 10, 27).toIso8601String(),
//   ),
//   Categories(
//     categoryId: 13,
//     categoryName: "Rumah Tangga",
//     dateAdded: DateTime(2022, 3, 6).toIso8601String(),
//   ),
//   Categories(
//     categoryId: 14,
//     categoryName: "Seni dan Kreativitas",
//     dateAdded: DateTime(2021, 12, 15).toIso8601String(),
//   ),
//   Categories(
//     categoryId: 15,
//     categoryName: "Toko",
//     dateAdded: DateTime(2023, 7, 20).toIso8601String(),
//   ),
// ];
