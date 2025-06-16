class TokenPayload {
  final int serialNumberId;
  final String serialNumber;
  final String name;
  final String email;
  final String phoneNumber;
  final int iat;
  final int exp;

  TokenPayload({
    required this.serialNumberId,
    required this.serialNumber,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.iat,
    required this.exp,
  });

  factory TokenPayload.fromJson(Map<String, dynamic> json) {
    return TokenPayload(
      serialNumberId: json['serialNumberId'] ?? json['id']?.toString() ?? '',
      serialNumber: json['serialNumber'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      iat: json['iat'] ?? 0,
      exp: json['exp'] ?? 0,
    );
  }
}