package com.example.kursach.core.storage

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import java.util.concurrent.atomic.AtomicReference

object SecurePreferencesHolder {
    private val prefsRef = AtomicReference<SharedPreferences?>()

    fun set(prefs: SharedPreferences) {
        prefsRef.set(prefs)
    }

    fun get(): SharedPreferences =
        prefsRef.get() ?: error("EncryptedSharedPreferences not initialized yet")

    fun getOrCreate(context: Context): SharedPreferences {
        prefsRef.get()?.let { return it }
        return synchronized(this) {
            prefsRef.get() ?: createEncryptedPreferences(context).also { prefsRef.set(it) }
        }
    }

    private fun createEncryptedPreferences(context: Context): SharedPreferences {
        val masterKey = MasterKey.Builder(context)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build()
        return EncryptedSharedPreferences.create(
            context,
            PREFS_NAME,
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
        )
    }

    private const val PREFS_NAME = "kursach_secure_storage"
}
