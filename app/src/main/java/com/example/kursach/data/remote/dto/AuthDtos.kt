package com.example.kursach.data.remote.dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class LoginRequestDto(
    val email: String,
    val password: String,
)

@Serializable
data class RegisterRequestDto(
    val email: String,
    val password: String,
    @SerialName("first_name") val firstName: String,
    @SerialName("last_name") val lastName: String,
    @SerialName("birth_date") val birthDate: String,
    val region: String,
    val city: String,
)

@Serializable
data class AuthTokenResponseDto(
    @SerialName("access_token") val accessToken: String,
    @SerialName("token_type") val tokenType: String,
)

@Serializable
data class MessageResponseDto(
    val message: String,
)
