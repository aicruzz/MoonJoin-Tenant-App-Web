class CustomValidator {
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }

  static bool isStrongPassword(String value) {
    if (value.length < 8) return false;
    final hasLetter = value.contains(RegExp(r'[A-Za-z]'));
    final hasNumber = value.contains(RegExp(r'\d'));
    return hasLetter && hasNumber;
  }

  static bool isPhone(String value) {
    return RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value);
  }
}
