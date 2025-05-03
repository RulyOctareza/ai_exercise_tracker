class User {
  final String id;
  final String email;
  final String? name;
  final DateTime? birthDate;
  final double? height; // in cm
  final double? weight; // in kg
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.birthDate,
    this.height,
    this.weight,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate BMI if height and weight are available
  double? get bmi {
    if (height == null || weight == null || height! <= 0) return null;
    // BMI = weight(kg) / (height(m))²
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  // BMI Category based on standard ranges
  String? get bmiCategory {
    final calculatedBmi = bmi;
    if (calculatedBmi == null) return null;

    if (calculatedBmi < 18.5) {
      return 'Underweight';
    } else if (calculatedBmi < 25) {
      return 'Normal';
    } else if (calculatedBmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? birthDate,
    double? height,
    double? weight,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
