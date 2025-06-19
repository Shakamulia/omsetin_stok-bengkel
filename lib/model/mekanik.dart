// Model untuk Mekanik
class Mekanik {
  int? id;
  String? profileImage;
  String namaMekanik;
  String spesialis;
  String noHandphone;
  String gender;
  String alamat;

  Mekanik({
    this.id,
    this.profileImage,
    required this.namaMekanik,
    required this.spesialis,
    required this.noHandphone,
    required this.gender,
    required this.alamat,
  });

    factory Mekanik.fromJson(Map<String, dynamic> json) {
    return Mekanik(
      id: json['id'],
      profileImage: json['profileImage'],
      namaMekanik: json['namaMekanik'],
      noHandphone: json['noHandphone'],
      spesialis: json['spesialis'],
      gender: json['gender'],
      alamat: json['alamat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaMekanik': namaMekanik,
      'noHandphone': noHandphone,
      'spesialis': spesialis,
      'gender': gender,
      'alamat': alamat,
      'profileImage': profileImage, // Make sure this matches your column name
    };
  }

  // Convert to Map untuk database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileImage': profileImage,
      'namaMekanik': namaMekanik,
      'spesialis': spesialis,
      'noHandphone': noHandphone,
      'gender': gender,
      'alamat': alamat,
    };
  }

  // Create from Map
  factory Mekanik.fromMap(Map<String, dynamic> map) {
    return Mekanik(
      id: map['id'],
      profileImage: map['profileImage'],
      namaMekanik: map['namaMekanik'],
      spesialis: map['spesialis'],
      noHandphone: map['noHandphone'],
      gender: map['gender'],
      alamat: map['alamat'],
    );
  }
}
