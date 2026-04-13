class Operator {
  const Operator({
    required this.phone,
    required this.name,
  });

  final String phone;
  final String name;

  factory Operator.fromJson(Map<String, Object?> json) {
    return Operator(
      phone: (json['phone'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
    );
  }
}

