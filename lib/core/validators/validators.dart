abstract final class Validators {
  static const _emailRegex =
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$';
  static const _phoneRegex = r'^\+?[0-9]{8,15}$';
  static const _urlRegex =
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    if (!RegExp(_emailRegex).hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters.';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required.';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required.';
    if (!RegExp(_phoneRegex).hasMatch(value.trim())) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return 'URL is required.';
    if (!RegExp(_urlRegex).hasMatch(value.trim())) {
      return 'Enter a valid URL.';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String fieldName = 'Field'}) {
    if (value == null || value.length < min) {
      return '$fieldName must be at least $min characters.';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String fieldName = 'Field'}) {
    if (value != null && value.length > max) {
      return '$fieldName must be at most $max characters.';
    }
    return null;
  }

  static String? compose(String? value, List<String? Function(String?)> rules) {
    for (final rule in rules) {
      final error = rule(value);
      if (error != null) return error;
    }
    return null;
  }
}
