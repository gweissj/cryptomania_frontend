package com.example.kursach.presentation.common

object ValidationUtils {

    fun validateEmail(value: String): String? {
        if (value.isBlank()) {
            return TEXT_ENTER_EMAIL
        }
        if (!value.contains("@")) {
            return TEXT_EMAIL_NEEDS_AT
        }
        if (!value.contains(".")) {
            return TEXT_EMAIL_NEEDS_DOT
        }
        return null
    }

    fun validatePassword(value: String): String? {
        if (value.length < MIN_PASSWORD_LENGTH) {
            return String.format(TEXT_PASSWORD_MIN_LENGTH, MIN_PASSWORD_LENGTH)
        }
        if (!value.any { it.isLetter() }) {
            return TEXT_PASSWORD_NEEDS_LETTER
        }
        return null
    }

    fun validateRequired(value: String, fieldName: String): String? =
        if (value.isBlank()) "$fieldName $TEXT_REQUIRED_SUFFIX" else null

    fun validatePasswordConfirmation(password: String, repeat: String): String? {
        if (repeat.isBlank()) {
            return TEXT_REPEAT_PASSWORD
        }
        if (password != repeat) {
            return TEXT_PASSWORDS_DIFFER
        }
        return null
    }

    private const val MIN_PASSWORD_LENGTH = 8

    private const val TEXT_ENTER_EMAIL = "\u0412\u0432\u0435\u0434\u0438\u0442\u0435 e-mail"
    private const val TEXT_EMAIL_NEEDS_AT = "E-mail \u0434\u043e\u043b\u0436\u0435\u043d \u0441\u043e\u0434\u0435\u0440\u0436\u0430\u0442\u044c \u0441\u0438\u043c\u0432\u043e\u043b @"
    private const val TEXT_EMAIL_NEEDS_DOT = "E-mail \u0434\u043e\u043b\u0436\u0435\u043d \u0441\u043e\u0434\u0435\u0440\u0436\u0430\u0442\u044c \u0442\u043e\u0447\u043a\u0443"
    private const val TEXT_PASSWORD_MIN_LENGTH =
        "\u041f\u0430\u0440\u043e\u043b\u044c \u0434\u043e\u043b\u0436\u0435\u043d \u0441\u043e\u0434\u0435\u0440\u0436\u0430\u0442\u044c \u043c\u0438\u043d\u0438\u043c\u0443\u043c %d \u0441\u0438\u043c\u0432\u043e\u043b\u043e\u0432"
    private const val TEXT_PASSWORD_NEEDS_LETTER =
        "\u041f\u0430\u0440\u043e\u043b\u044c \u0434\u043e\u043b\u0436\u0435\u043d \u0441\u043e\u0434\u0435\u0440\u0436\u0430\u0442\u044c \u0445\u043e\u0442\u044f \u0431\u044b \u043e\u0434\u043d\u0443 \u0431\u0443\u043a\u0432\u0443"
    private const val TEXT_REQUIRED_SUFFIX = "\u043e\u0431\u044f\u0437\u0430\u0442\u0435\u043b\u044c\u043d\u043e"
    private const val TEXT_REPEAT_PASSWORD = "\u041f\u043e\u0432\u0442\u043e\u0440\u0438\u0442\u0435 \u043f\u0430\u0440\u043e\u043b\u044c"
    private const val TEXT_PASSWORDS_DIFFER =
        "\u041f\u0430\u0440\u043e\u043b\u0438 \u043d\u0435 \u0441\u043e\u0432\u043f\u0430\u0434\u0430\u044e\u0442"
}
