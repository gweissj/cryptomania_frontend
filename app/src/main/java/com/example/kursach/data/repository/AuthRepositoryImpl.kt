package com.example.kursach.data.repository

import com.example.kursach.core.di.IoDispatcher
import com.example.kursach.core.storage.SessionStorage
import com.example.kursach.data.remote.KursachApi
import com.example.kursach.data.remote.dto.LoginRequestDto
import com.example.kursach.data.remote.dto.RegisterRequestDto
import com.example.kursach.data.remote.mappers.toDomain
import com.example.kursach.domain.model.UserProfile
import com.example.kursach.domain.repository.AuthRepository
import com.example.kursach.domain.usecase.RegistrationData
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.withContext
import retrofit2.HttpException
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthRepositoryImpl @Inject constructor(
    private val api: KursachApi,
    private val sessionStorage: SessionStorage,
    @IoDispatcher private val ioDispatcher: CoroutineDispatcher,
) : AuthRepository {

    override suspend fun login(email: String, password: String): Result<UserProfile> =
        withContext(ioDispatcher) {
            runCatching {
                val tokenResponse = api.login(LoginRequestDto(email = email, password = password))
                sessionStorage.saveToken(tokenResponse.accessToken)
                api.fetchCurrentUser().toDomain()
            }.onFailure {
                sessionStorage.clear()
            }
        }

    override suspend fun register(data: RegistrationData): Result<UserProfile> =
        withContext(ioDispatcher) {
            runCatching {
                api.register(
                    RegisterRequestDto(
                        email = data.email,
                        password = data.password,
                        firstName = data.firstName,
                        lastName = data.lastName,
                        birthDate = data.birthDate,
                        region = data.region,
                        city = data.city,
                    ),
                )
                val tokenResponse = api.login(LoginRequestDto(email = data.email, password = data.password))
                sessionStorage.saveToken(tokenResponse.accessToken)
                api.fetchCurrentUser().toDomain()
            }.onFailure {
                sessionStorage.clear()
            }
        }

    override suspend fun fetchProfile(forceRefresh: Boolean): Result<UserProfile> =
        withContext(ioDispatcher) {
            val token = sessionStorage.authToken.value
            if (token.isNullOrBlank()) {
                return@withContext Result.failure(IllegalStateException(ERROR_NO_SESSION))
            }
            runCatching {
                api.fetchCurrentUser().toDomain()
            }.onFailure { error ->
                if (error is HttpException && error.code() == 401) {
                    sessionStorage.clear()
                }
            }
        }

    override suspend fun logout(): Result<Unit> =
        withContext(ioDispatcher) {
            runCatching {
                api.logout()
                sessionStorage.clear()
            }.onFailure {
                sessionStorage.clear()
            }
        }
}

private const val ERROR_NO_SESSION = "\u0421\u0435\u0441\u0441\u0438\u044f \u043d\u0435 \u043d\u0430\u0439\u0434\u0435\u043d\u0430"
