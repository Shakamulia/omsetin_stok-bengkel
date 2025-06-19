import 'dart:math';


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
    required this.alamat,  });

    Pelanggan.minimal({
    required this.id,
    required this.namaPelanggan,
    this.kode = '',
    this.noHandphone = '',
    this.email = '',
    this.gender = '',
    this.alamat = '',
  });


  factory Pelanggan.fromJson(Map<String, dynamic> json) {
    return Pelanggan(
      id: json['id'],
      profileImage: json['profileImage'],
      kode: json['kode'],
      namaPelanggan: json['namaPelanggan'],
      noHandphone: json['noHandphone'],
      email: json['email'],
      gender: json['gender'],
      alamat: json['alamat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode': kode,
      'namaPelanggan': namaPelanggan,
      'noHandphone': noHandphone,
      'email': email,
      'gender': gender,
      'alamat': alamat,
      'profileImage': profileImage, // Make sure this matches your column name
    };
  }


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
  factory Pelanggan.fromMap(Map<String, dynamic> json) {
    return Pelanggan(
      id: json['id'],
      profileImage: json['profileImage'],
      kode: json['kode'],
      namaPelanggan: json['namaPelanggan'],
      noHandphone: json['noHandphone'],
      email: json['email'],
      gender: json['gender'],
      alamat: json['alamat'],
    );
  }

}

