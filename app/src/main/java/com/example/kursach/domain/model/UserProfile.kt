package com.example.kursach.domain.model

import java.time.Instant
import java.time.LocalDate

data class UserProfile(
    val id: Int,
    val email: String,
    val firstName: String,
    val lastName: String,
    val birthDate: LocalDate,
    val region: String,
    val city: String,
    val createdAt: Instant,
    val updatedAt: Instant,
) {
    val fullName: String
        get() = "$firstName $lastName"
}
