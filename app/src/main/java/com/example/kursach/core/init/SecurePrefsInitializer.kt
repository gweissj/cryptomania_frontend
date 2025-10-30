package com.example.kursach.core.init

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import androidx.startup.Initializer
import com.example.kursach.core.storage.SecurePreferencesHolder

class SecurePrefsInitializer : Initializer<SharedPreferences> {

    override fun create(context: Context): SharedPreferences {
        val masterKey = MasterKey.Builder(context)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build()

        val prefs = EncryptedSharedPreferences.create(
            context,
            PREFS_NAME,
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
        )
        SecurePreferencesHolder.set(prefs)
        return prefs
    }

    override fun dependencies(): List<Class<out Initializer<*>>> = emptyList()

    private companion object {
        private const val PREFS_NAME = "kursach_secure_storage"
    }
}
