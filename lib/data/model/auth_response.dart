class AuthResponse {
  final bool success;
  final String? message;
  final User? user;
  final String? accessToken;
  final String? refreshToken;

  AuthResponse({
    required this.success,
    this.message,
    this.user,
    this.accessToken,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user?.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
}

class User {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? email;
  final String? avatar;

  User({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.email,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }
}
