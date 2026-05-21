class SocialLoginBody {
  final String token;
  final String? email;
  final String? name;
  final String provider;

  SocialLoginBody({
    required this.token,
    required this.provider,
    this.email,
    this.name,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'provider': provider,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
      };
}
