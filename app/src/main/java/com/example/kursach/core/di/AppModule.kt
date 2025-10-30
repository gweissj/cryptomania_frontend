package com.example.kursach.core.di

import android.content.Context
import android.content.SharedPreferences
import com.example.kursach.BuildConfig
import com.example.kursach.core.network.AuthInterceptor
import com.example.kursach.core.network.SessionAuthenticator
import com.example.kursach.core.storage.SecurePreferencesHolder
import com.example.kursach.core.storage.SecureSessionStorage
import com.example.kursach.core.storage.SessionStorage
import com.example.kursach.data.remote.KursachApi
import com.example.kursach.data.repository.AuthRepositoryImpl
import com.example.kursach.domain.repository.AuthRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import javax.inject.Qualifier
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideSharedPreferences(
        @ApplicationContext context: Context,
    ): SharedPreferences = SecurePreferencesHolder.getOrCreate(context)

    @Provides
    @Singleton
    fun provideSessionStorage(storage: SecureSessionStorage): SessionStorage = storage

    @Provides
    @Singleton
    fun provideJson(): Json = Json {
        ignoreUnknownKeys = true
        isLenient = true
        encodeDefaults = true
    }

    @Provides
    @Singleton
    fun provideLoggingInterceptor(): HttpLoggingInterceptor =
        HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        }

    @Provides
    @Singleton
    fun provideOkHttpClient(
        loggingInterceptor: HttpLoggingInterceptor,
        authInterceptor: AuthInterceptor,
        sessionAuthenticator: SessionAuthenticator,
    ): OkHttpClient =
        OkHttpClient.Builder()
            .addInterceptor(authInterceptor)
            .addInterceptor(loggingInterceptor)
            .authenticator(sessionAuthenticator)
            .build()

    @Provides
    @Singleton
    fun provideRetrofit(
        okHttpClient: OkHttpClient,
        json: Json,
    ): Retrofit =
        Retrofit.Builder()
            .baseUrl(BuildConfig.API_BASE_URL)
            .client(okHttpClient)
            .addConverterFactory(json.asConverterFactory(JSON_MEDIA_TYPE))
            .build()

    @Provides
    @Singleton
    fun provideKursachApi(retrofit: Retrofit): KursachApi = retrofit.create(KursachApi::class.java)

    @Provides
    @Singleton
    fun provideAuthRepository(impl: AuthRepositoryImpl): AuthRepository = impl

    @Provides
    @Singleton
    @IoDispatcher
    fun provideIoDispatcher(): CoroutineDispatcher = Dispatchers.IO

    private val JSON_MEDIA_TYPE = "application/json".toMediaType()
}

@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class IoDispatcher
