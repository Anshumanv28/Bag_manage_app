class Operator {
  const Operator({
    required this.phone,
    required this.name,
    this.depositEnabled = true,
    this.retrieveEnabled = true,
  });

  final String phone;
  final String name;
  final bool depositEnabled;
  final bool retrieveEnabled;

  factory Operator.fromJson(Map<String, Object?> json) {
    return Operator(
      phone: (json['phone'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      depositEnabled: json['depositEnabled'] as bool? ?? true,
      retrieveEnabled: json['retrieveEnabled'] as bool? ?? true,
    );
  }
}
