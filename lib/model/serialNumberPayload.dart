class SerialNumberPayload {
  final String id;
  final String serialNumber;
  final String name;
  final String email;
  final String phoneNumber;
  final String profileImage;
  final bool isActive;
  final String lastLoginAt;
  final String? createdAt;
  final String updatedAt;

  SerialNumberPayload({
    required this.id,
    required this.serialNumber,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profileImage,
    required this.isActive,
    required this.lastLoginAt,
    this.createdAt,
    required this.updatedAt,
  });

  factory SerialNumberPayload.fromJson(Map<String, dynamic> json) {
    return SerialNumberPayload(
      id: json['id']?.toString() ?? '',
      serialNumber: json['serialNumber'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profileImage: json['profileImage'] ?? '',
      isActive: json['is_active'] ?? false,
      lastLoginAt: json['last_login_at'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'] ?? '',
    );
  }

  @override
  String toString() {
    return 'SerialNumberPayload(id: $id, serialNumber: $serialNumber, name: $name, email: $email, phoneNumber: $phoneNumber, profileImage: $profileImage, isActive: $isActive, lastLoginAt: $lastLoginAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}