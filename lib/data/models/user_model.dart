// lib/data/models/user_model.dart
import '../../domain/entities/user.dart' as entity;

class UserModel extends entity.User {
  UserModel({
    required super.id,
    required super.email,
    super.name,
    super.birthDate,
    super.height,
    super.weight,
    super.photoUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromEntity(entity.User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      birthDate: user.birthDate,
      height: user.height,
      weight: user.weight,
      photoUrl: user.photoUrl,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      birthDate:
          json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'birthDate': birthDate?.toIso8601String(),
      'height': height,
      'weight': weight,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
