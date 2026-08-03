import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';

/// Data-layer model representing a Firebase Auth user.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.phoneNumber,
    super.photoUrl,
    super.provider,
    super.isEmailVerified,
  });

  /// Maps a Firebase [User] to a [UserModel].
  factory UserModel.fromFirebaseUser(User? user) {
    if (user == null) {
      throw ArgumentError('Firebase user cannot be null.');
    }

    String? provider = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : null;

    if (provider == 'firebase' && user.phoneNumber != null) {
      provider = 'phone';
    }

    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
      provider: provider,
      isEmailVerified: user.emailVerified,
    );
  }

  /// Converts this model to a domain [UserEntity].
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
      provider: provider,
      isEmailVerified: isEmailVerified,
    );
  }

  /// Deserializes from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      provider: json['provider'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );
  }

  /// Serializes to a JSON map for caching.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'provider': provider,
      'isEmailVerified': isEmailVerified,
    };
  }
}
