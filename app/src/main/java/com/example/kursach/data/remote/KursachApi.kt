package com.example.kursach.data.remote

import com.example.kursach.data.remote.dto.AuthTokenResponseDto
import com.example.kursach.data.remote.dto.LoginRequestDto
import com.example.kursach.data.remote.dto.MessageResponseDto
import com.example.kursach.data.remote.dto.RegisterRequestDto
import com.example.kursach.data.remote.dto.UserResponseDto
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST

interface KursachApi {

    @POST("auth/login")
    suspend fun login(@Body request: LoginRequestDto): AuthTokenResponseDto

    @POST("auth/register")
    suspend fun register(@Body request: RegisterRequestDto): UserResponseDto

    @GET("users/me")
    suspend fun fetchCurrentUser(): UserResponseDto

    @POST("auth/logout")
    suspend fun logout(): MessageResponseDto
}
