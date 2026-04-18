class Validators {
  static String? validateEmail(String? value, {
    required String requiredMessage,
    required String invalidMessage,
  }) {
    if (value == null || value.isEmpty) {
      return requiredMessage;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return invalidMessage;
    }
    return null;
  }

  static String? validatePassword(String? value, {
    required String requiredMessage,
    required String tooShortMessage,
  }) {
    if (value == null || value.isEmpty) {
      return requiredMessage;
    }
    if (value.length < 6) {
      return tooShortMessage;
    }
    return null;
  }

  static String? validatePhone(String? value, {
    required String requiredMessage,
    required String invalidMessage,
  }) {
    if (value == null || value.isEmpty) {
      return requiredMessage;
    }
    final phoneRegex = RegExp(r'^0\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return invalidMessage;
    }
    return null;
  }

  static String? validateRequired(String? value, {
    required String requiredMessage,
  }) {
    if (value == null || value.isEmpty) {
      return requiredMessage;
    }
    return null;
  }

  static String? validatePrice(String? value, {
    required String requiredMessage,
    required String invalidMessage,
  }) {
    if (value == null || value.isEmpty) {
      return requiredMessage;
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return invalidMessage;
    }
    return null;
  }
}