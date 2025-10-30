package com.example.kursach.data.remote.mappers

import com.example.kursach.data.remote.dto.UserResponseDto
import com.example.kursach.domain.model.UserProfile
import java.time.Instant
import java.time.LocalDate

fun UserResponseDto.toDomain(): UserProfile =
    UserProfile(
        id = id,
        email = email,
        firstName = firstName,
        lastName = lastName,
        birthDate = LocalDate.parse(birthDate),
        region = region,
        city = city,
        createdAt = Instant.parse(createdAt),
        updatedAt = Instant.parse(updatedAt),
    )
