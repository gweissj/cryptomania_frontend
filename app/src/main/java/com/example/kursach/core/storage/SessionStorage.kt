package com.example.kursach.core.storage

import android.content.SharedPreferences
import androidx.core.content.edit
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject
import javax.inject.Singleton

interface SessionStorage {
    val authToken: StateFlow<String?>
    fun saveToken(token: String)
    fun clear()
}

@Singleton
class SecureSessionStorage @Inject constructor(
    private val prefs: SharedPreferences,
) : SessionStorage {

    private val tokenFlow = MutableStateFlow(prefs.getString(KEY_AUTH_TOKEN, null))

    private val changeListener =
        SharedPreferences.OnSharedPreferenceChangeListener { sharedPrefs, key ->
            if (key == KEY_AUTH_TOKEN) {
                tokenFlow.value = sharedPrefs.getString(KEY_AUTH_TOKEN, null)
            }
        }

    init {
        prefs.registerOnSharedPreferenceChangeListener(changeListener)
    }

    override val authToken: StateFlow<String?> = tokenFlow.asStateFlow()

    override fun saveToken(token: String) {
        tokenFlow.value = token
        prefs.edit {
            putString(KEY_AUTH_TOKEN, token)
        }
    }

    override fun clear() {
        tokenFlow.value = null
        prefs.edit { remove(KEY_AUTH_TOKEN) }
    }

    private companion object {
        private const val KEY_AUTH_TOKEN = "auth_token"
    }
}
