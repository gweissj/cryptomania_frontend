package com.example.kursach.domain.repository

import com.example.kursach.domain.model.UserProfile
import com.example.kursach.domain.usecase.RegistrationData

interface AuthRepository {
    suspend fun login(email: String, password: String): Result<UserProfile>
    suspend fun register(data: RegistrationData): Result<UserProfile>
    suspend fun fetchProfile(forceRefresh: Boolean = false): Result<UserProfile>
    suspend fun logout(): Result<Unit>
}
