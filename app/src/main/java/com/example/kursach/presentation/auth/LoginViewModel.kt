package com.example.kursach.presentation.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.kursach.domain.model.UserProfile
import com.example.kursach.domain.repository.AuthRepository
import com.example.kursach.presentation.common.ValidationUtils.validateEmail
import com.example.kursach.presentation.common.ValidationUtils.validatePassword
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import retrofit2.HttpException
import javax.inject.Inject

@HiltViewModel
class LoginViewModel @Inject constructor(
    private val authRepository: AuthRepository,
) : ViewModel() {

    private val mutableState = MutableStateFlow(LoginUiState())
    val uiState = mutableState.asStateFlow()

    private val mutableEffects = MutableSharedFlow<LoginEffect>()
    val effects = mutableEffects.asSharedFlow()

    fun onEmailChanged(value: String) {
        mutableState.update { it.copy(email = value, emailError = null, generalError = null) }
    }

    fun onPasswordChanged(value: String) {
        mutableState.update { it.copy(password = value, passwordError = null, generalError = null) }
    }

    fun submit() {
        val current = mutableState.value
        val emailError = validateEmail(current.email)
        val passwordError = validatePassword(current.password)
        if (emailError != null || passwordError != null) {
            mutableState.update {
                it.copy(
                    emailError = emailError,
                    passwordError = passwordError,
                )
            }
            return
        }

        viewModelScope.launch {
            mutableState.update { it.copy(isLoading = true, generalError = null) }
            val result = authRepository.login(current.email.trim(), current.password)
            result
                .onSuccess { profile ->
                    mutableState.update { it.copy(isLoading = false) }
                    mutableEffects.emit(LoginEffect.Success(profile))
                }
                .onFailure { error ->
                    mutableState.update {
                        it.copy(
                            isLoading = false,
                            generalError = mapError(error),
                        )
                    }
                }
        }
    }

    private fun mapError(throwable: Throwable): String = when (throwable) {
        is HttpException -> when (throwable.code()) {
            400, 401 -> TEXT_INVALID_CREDENTIALS
            else -> String.format(TEXT_SERVER_ERROR, throwable.code())
        }

        else -> throwable.message ?: TEXT_UNKNOWN_ERROR
    }
}

data class LoginUiState(
    val email: String = "",
    val password: String = "",
    val emailError: String? = null,
    val passwordError: String? = null,
    val generalError: String? = null,
    val isLoading: Boolean = false,
) {
    val canSubmit: Boolean
        get() = email.isNotBlank() && password.isNotBlank() && !isLoading
}

sealed interface LoginEffect {
    data class Success(val profile: UserProfile) : LoginEffect
}

private const val TEXT_INVALID_CREDENTIALS =
    "\u041d\u0435\u0432\u0435\u0440\u043d\u044b\u0439 e-mail \u0438\u043b\u0438 \u043f\u0430\u0440\u043e\u043b\u044c"
private const val TEXT_SERVER_ERROR = "\u041e\u0448\u0438\u0431\u043a\u0430 \u0441\u0435\u0440\u0432\u0435\u0440\u0430: %d"
private const val TEXT_UNKNOWN_ERROR =
    "\u041f\u0440\u043e\u0438\u0437\u043e\u0448\u043b\u0430 \u043d\u0435\u0438\u0437\u0432\u0435\u0441\u0442\u043d\u0430\u044f \u043e\u0448\u0438\u0431\u043a\u0430"
