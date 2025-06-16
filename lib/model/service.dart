class Service {
  int? id;
  String name;
  double price;
  String dateAdded;

  Service({
    this.id,
    required this.name,
    required this.price,
    required this.dateAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'service_id': id,
      'service_name': name,
      'service_price': price,
      'service_date_added': dateAdded,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['service_id'],
      name: map['service_name'],
      price: map['service_price'],
      dateAdded: map['service_date_added'],
    );
  }

  // Tambahkan method copy
  Service copy() {
    return Service(
      id: id,
      name: name,
      price: price,
      dateAdded: dateAdded,
      // ... properti lainnya
    );
  }
}
