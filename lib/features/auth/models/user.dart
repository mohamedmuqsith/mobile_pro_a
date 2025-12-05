class User {
  final int? id;
  final String email;
  final String password;
  final String name;
  final int age;
  final String? gender;
  final double height;
  final double weight;
  final String? profileImagePath;
  final String createdAt;
  final String updatedAt;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.name,
    this.age = 0,
    this.gender,
    this.height = 0.0,
    this.weight = 0.0,
    this.profileImagePath,
    String? createdAt,
    String? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now().toIso8601String(),
        updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'profile_image_path': profileImagePath,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      password: map['password'] as String,
      name: map['name'] as String,
      age: map['age'] as int? ?? 0,
      gender: map['gender'] as String?,
      height: (map['height'] as num?)?.toDouble() ?? 0.0,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      profileImagePath: map['profile_image_path'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  User copyWith({
    int? id,
    String? email,
    String? password,
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? profileImagePath,
    String? createdAt,
    String? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  // Create user without password (for display purposes)
  User withoutPassword() {
    return copyWith(password: '');
  }

  // Validation
  String? validateEmail() {
    if (email.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Invalid email format';
    }
    return null;
  }

  String? validatePassword() {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateName() {
    if (name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  bool get isValid {
    return validateEmail() == null &&
        validatePassword() == null &&
        validateName() == null;
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, age: $age)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User && other.id == id && other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode;
  }
}
