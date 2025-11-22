class ValidationUtils {
  const ValidationUtils._();

  static String? validateEmail(String value) {
    if (value.trim().isEmpty) {
      return _textEnterEmail;
    }
    if (!value.contains('@')) {
      return _textEmailNeedsAt;
    }
    if (!value.contains('.')) {
      return _textEmailNeedsDot;
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.length < _minPasswordLength) {
      return 'Пароль должен содержать минимум $_minPasswordLength символов';
    }
    if (!value.split('').any((c) => RegExp(r'[A-Za-zА-Яа-я]').hasMatch(c))) {
      return 'Пароль должен содержать хотя бы одну букву';
    }
    return null;
  }

  static String? validateRequired(String value, String fieldName) {
    if (value.trim().isEmpty) {
      return '$fieldName обязательно';
    }
    return null;
  }

  static String? validatePasswordConfirmation(String password, String repeat) {
    if (repeat.trim().isEmpty) {
      return 'Повторите пароль';
    }
    if (password != repeat) {
      return 'Пароли не совпадают';
    }
    return null;
  }

  static String? validateAdult(DateTime? birthDate, {int minAge = 18}) {
    if (birthDate == null) {
      return '������� ���� ��������';
    }
    final now = DateTime.now();
    final years = now.year - birthDate.year;
    final hasHadBirthday =
        (now.month > birthDate.month) ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    final age = hasHadBirthday ? years : years - 1;
    if (age < minAge) {
      return '��⮬�� �� ������� 18 ���';
    }
    return null;
  }

  static const int _minPasswordLength = 8;
  static const _textEnterEmail = 'Введите e-mail';
  static const _textEmailNeedsAt = 'E-mail должен содержать символ @';
  static const _textEmailNeedsDot = 'E-mail должен содержать точку';
}
