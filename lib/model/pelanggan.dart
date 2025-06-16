import 'dart:math';

// Model untuk Pelanggan
class Pelanggan {
  int? id;
  String? profileImage;
  String kode;
  String namaPelanggan;
  String noHandphone;
  String email;
  String gender;
  String alamat;

  Pelanggan({
    this.id,
    this.profileImage,
    required this.kode,
    required this.namaPelanggan,
    required this.noHandphone,
    required this.email,
    required this.gender,
    required this.alamat,
  });

  // TAMBAHKAN KODE INI =========================
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Pelanggan && other.id == id && other.kode == kode;
  }

  @override
  int get hashCode => id.hashCode ^ kode.hashCode;
  // ============================================

  // Convert to Map untuk database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileImage': profileImage, // Make sure this matches your column name
      'kode': kode,
      'namaPelanggan': namaPelanggan,
      'noHandphone': noHandphone,
      'email': email,
      'gender': gender,
      'alamat': alamat,
    };
  }

  // Create from Map
  factory Pelanggan.fromMap(Map<String, dynamic> map) {
    return Pelanggan(
      id: map['id'],
      profileImage: map['profileImage'],
      kode: map['kode'],
      namaPelanggan: map['namaPelanggan'],
      noHandphone: map['noHandphone'],
      email: map['email'],
      gender: map['gender'],
      alamat: map['alamat'],
    );
  }
}
