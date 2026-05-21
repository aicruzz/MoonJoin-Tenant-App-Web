class SignUpBodyModel {
  final String companyName;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;
  final String? countryCode;

  SignUpBodyModel({
    required this.companyName,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    this.countryCode,
  });

  Map<String, dynamic> toJson() => {
        'company_name': companyName,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (countryCode != null) 'country_code': countryCode,
      };
}
