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
