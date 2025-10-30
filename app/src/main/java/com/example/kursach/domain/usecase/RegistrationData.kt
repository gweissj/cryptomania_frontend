package com.example.kursach.domain.usecase

data class RegistrationData(
    val firstName: String,
    val lastName: String,
    val email: String,
    val password: String,
    val birthDate: String,
    val region: String,
    val city: String,
)
