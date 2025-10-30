package com.example.kursach.presentation.session

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.kursach.domain.model.UserProfile
import com.example.kursach.domain.repository.AuthRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import retrofit2.HttpException
import javax.inject.Inject

@HiltViewModel
class SessionViewModel @Inject constructor(
    private val authRepository: AuthRepository,
) : ViewModel() {

    private val mutableState = MutableStateFlow(SessionUiState(isLoading = true))
    val state = mutableState.asStateFlow()

    init {
        refreshSession()
    }

    fun refreshSession() {
        viewModelScope.launch {
            mutableState.update { it.copy(isLoading = true, error = null) }
            val result = authRepository.fetchProfile()
            result
                .onSuccess { profile ->
                    mutableState.update {
                        SessionUiState(
                            isLoading = false,
                            user = profile,
                            error = null,
                        )
                    }
                }
                .onFailure { error ->
                    mutableState.update {
                        SessionUiState(
                            isLoading = false,
                            user = null,
                            error = mapError(error),
                        )
                    }
                }
        }
    }

    fun setAuthenticated(profile: UserProfile) {
        mutableState.value = SessionUiState(isLoading = false, user = profile, error = null)
    }

    fun logout() {
        viewModelScope.launch {
            mutableState.update { it.copy(isLoading = true) }
            val result = authRepository.logout()
            result
                .onSuccess {
                    mutableState.update { SessionUiState(isLoading = false, user = null, error = null) }
                }
                .onFailure { error ->
                    mutableState.update {
                        it.copy(
                            isLoading = false,
                            user = null,
                            error = mapError(error),
                        )
                    }
                }
        }
    }

    fun clearError() {
        mutableState.update { it.copy(error = null) }
    }

    private fun mapError(error: Throwable): String = when (error) {
        is HttpException -> when (error.code()) {
            401 -> TEXT_SESSION_EXPIRED
            else -> String.format(TEXT_SERVER_ERROR, error.code())
        }

        is IllegalStateException -> TEXT_NEED_LOGIN
        else -> error.message ?: TEXT_UNKNOWN_ERROR
    }
}

data class SessionUiState(
    val isLoading: Boolean = false,
    val user: UserProfile? = null,
    val error: String? = null,
) {
    val isAuthenticated: Boolean
        get() = user != null
}

private const val TEXT_SESSION_EXPIRED =
    "\u0421\u0435\u0441\u0441\u0438\u044f \u0438\u0441\u0442\u0435\u043a\u043b\u0430. \u041f\u043e\u0436\u0430\u043b\u0443\u0439\u0441\u0442\u0430, \u0432\u043e\u0439\u0434\u0438\u0442\u0435 \u0441\u043d\u043e\u0432\u0430."
private const val TEXT_SERVER_ERROR = "\u041e\u0448\u0438\u0431\u043a\u0430 \u0441\u0435\u0440\u0432\u0435\u0440\u0430: %d"
private const val TEXT_NEED_LOGIN = "\u041d\u0435\u043e\u0431\u0445\u043e\u0434\u0438\u043c\u043e \u0432\u043e\u0439\u0442\u0438 \u0432 \u0430\u043a\u043a\u0430\u0443\u043d\u0442"
private const val TEXT_UNKNOWN_ERROR = "\u0427\u0442\u043e-\u0442\u043e \u043f\u043e\u0448\u043b\u043e \u043d\u0435 \u0442\u0430\u043a"
