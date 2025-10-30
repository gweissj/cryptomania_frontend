package com.example.kursach.core.network

import com.example.kursach.core.storage.SessionStorage
import okhttp3.Interceptor
import okhttp3.Response
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthInterceptor @Inject constructor(
    private val sessionStorage: SessionStorage,
) : Interceptor {

    override fun intercept(chain: Interceptor.Chain): Response {
        val token = sessionStorage.authToken.value
        val request = if (token.isNullOrBlank()) {
            chain.request()
        } else {
            chain.request()
                .newBuilder()
                .addHeader("Authorization", "Bearer $token")
                .build()
        }
        return chain.proceed(request)
    }
}
