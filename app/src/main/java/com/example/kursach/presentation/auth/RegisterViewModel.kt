package com.example.kursach.presentation.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.kursach.domain.model.UserProfile
import com.example.kursach.domain.repository.AuthRepository
import com.example.kursach.domain.usecase.RegistrationData
import com.example.kursach.presentation.common.ValidationUtils.validateEmail
import com.example.kursach.presentation.common.ValidationUtils.validatePassword
import com.example.kursach.presentation.common.ValidationUtils.validatePasswordConfirmation
import com.example.kursach.presentation.common.ValidationUtils.validateRequired
import dagger.hilt.android.lifecycle.HiltViewModel
import java.io.IOException
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import okhttp3.ResponseBody
import retrofit2.HttpException
import javax.inject.Inject

@HiltViewModel
class RegisterViewModel @Inject constructor(
    private val authRepository: AuthRepository,
) : ViewModel() {

    private val mutableState = MutableStateFlow(RegisterUiState())
    val uiState = mutableState.asStateFlow()

    private val mutableEffects = MutableSharedFlow<RegisterEffect>()
    val effects = mutableEffects.asSharedFlow()

    fun onFirstNameChanged(value: String) {
        mutableState.update { it.copy(firstName = value, firstNameError = null, generalError = null) }
    }

    fun onLastNameChanged(value: String) {
        mutableState.update { it.copy(lastName = value, lastNameError = null, generalError = null) }
    }

    fun onEmailChanged(value: String) {
        mutableState.update { it.copy(email = value, emailError = null, generalError = null) }
    }

    fun onPasswordChanged(value: String) {
        mutableState.update { it.copy(password = value, passwordError = null, generalError = null) }
    }

    fun onRepeatPasswordChanged(value: String) {
        mutableState.update { it.copy(repeatPassword = value, repeatPasswordError = null, generalError = null) }
    }

    fun onRegionChanged(value: String) {
        mutableState.update { it.copy(region = value, regionError = null, generalError = null) }
    }

    fun onCityChanged(value: String) {
        mutableState.update { it.copy(city = value, cityError = null, generalError = null) }
    }

    fun onBirthDateSelected(date: LocalDate) {
        mutableState.update { it.copy(birthDate = date, birthDateError = null, generalError = null) }
    }

    fun submit() {
        val current = mutableState.value
        val firstNameError = validateRequired(current.firstName, FIELD_FIRST_NAME)
        val lastNameError = validateRequired(current.lastName, FIELD_LAST_NAME)
        val emailError = validateEmail(current.email)
        val passwordError = validatePassword(current.password)
        val repeatPasswordError = validatePasswordConfirmation(current.password, current.repeatPassword)
        val regionError = validateRequired(current.region, FIELD_REGION)
        val cityError = validateRequired(current.city, FIELD_CITY)
        val birthDateError = if (current.birthDate == null) TEXT_SELECT_BIRTHDATE else null

        val hasErrors = listOf(
            firstNameError,
            lastNameError,
            emailError,
            passwordError,
            repeatPasswordError,
            regionError,
            cityError,
            birthDateError,
        ).any { it != null }

        if (hasErrors) {
            mutableState.update {
                it.copy(
                    firstNameError = firstNameError,
                    lastNameError = lastNameError,
                    emailError = emailError,
                    passwordError = passwordError,
                    repeatPasswordError = repeatPasswordError,
                    regionError = regionError,
                    cityError = cityError,
                    birthDateError = birthDateError,
                )
            }
            return
        }

        viewModelScope.launch {
            mutableState.update { it.copy(isLoading = true, generalError = null) }
            val request = RegistrationData(
                firstName = current.firstName.trim(),
                lastName = current.lastName.trim(),
                email = current.email.trim(),
                password = current.password,
                birthDate = current.birthDate?.format(DateTimeFormatter.ISO_LOCAL_DATE).orEmpty(),
                region = current.region.trim(),
                city = current.city.trim(),
            )
            val result = authRepository.register(request)
            result
                .onSuccess { profile ->
                    mutableState.update { it.copy(isLoading = false) }
                    mutableEffects.emit(RegisterEffect.Success(profile))
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
            400 -> parseErrorBody(throwable.response()?.errorBody())
            409 -> TEXT_USER_EXISTS
            else -> String.format(TEXT_SERVER_ERROR, throwable.code())
        }

        is IOException -> TEXT_NETWORK_ERROR
        else -> throwable.message ?: TEXT_UNKNOWN_ERROR
    }

    private fun parseErrorBody(body: ResponseBody?): String {
        val raw = body?.string().orEmpty()
        return if (raw.isNotBlank()) {
            raw.replace("\"", "").replace("{", "").replace("}", "")
        } else {
            TEXT_CHECK_INPUT
        }
    }
}

data class RegisterUiState(
    val firstName: String = "",
    val lastName: String = "",
    val email: String = "",
    val password: String = "",
    val repeatPassword: String = "",
    val birthDate: LocalDate? = null,
    val region: String = "",
    val city: String = "",
    val firstNameError: String? = null,
    val lastNameError: String? = null,
    val emailError: String? = null,
    val passwordError: String? = null,
    val repeatPasswordError: String? = null,
    val birthDateError: String? = null,
    val regionError: String? = null,
    val cityError: String? = null,
    val generalError: String? = null,
    val isLoading: Boolean = false,
) {
    val canSubmit: Boolean
        get() = listOf(firstName, lastName, email, password, repeatPassword, region, city)
            .all { it.isNotBlank() } && birthDate != null && !isLoading

    val formattedBirthDate: String
        get() = birthDate?.format(DateTimeFormatter.ofPattern("dd.MM.yyyy")).orEmpty()
}

sealed interface RegisterEffect {
    data class Success(val profile: UserProfile) : RegisterEffect
}

private const val FIELD_FIRST_NAME = "\u0418\u043c\u044f"
private const val FIELD_LAST_NAME = "\u0424\u0430\u043c\u0438\u043b\u0438\u044f"
private const val FIELD_REGION = "\u0420\u0435\u0433\u0438\u043e\u043d"
private const val FIELD_CITY = "\u0413\u043e\u0440\u043e\u0434"
private const val TEXT_SELECT_BIRTHDATE = "\u0423\u043a\u0430\u0436\u0438\u0442\u0435 \u0434\u0430\u0442\u0443 \u0440\u043e\u0436\u0434\u0435\u043d\u0438\u044f"
private const val TEXT_USER_EXISTS = "\u041f\u043e\u043b\u044c\u0437\u043e\u0432\u0430\u0442\u0435\u043b\u044c \u0441 \u0442\u0430\u043a\u0438\u043c e-mail \u0443\u0436\u0435 \u0441\u0443\u0449\u0435\u0441\u0442\u0432\u0443\u0435\u0442"
private const val TEXT_SERVER_ERROR = "\u041e\u0448\u0438\u0431\u043a\u0430 \u0441\u0435\u0440\u0432\u0435\u0440\u0430: %d"
private const val TEXT_NETWORK_ERROR = "\u041f\u0440\u043e\u0431\u043b\u0435\u043c\u044b \u0441 \u043f\u043e\u0434\u043a\u043b\u044e\u0447\u0435\u043d\u0438\u0435\u043c \u043a \u0441\u0435\u0442\u0438"
private const val TEXT_UNKNOWN_ERROR =
    "\u041f\u0440\u043e\u0438\u0437\u043e\u0448\u043b\u0430 \u043d\u0435\u0438\u0437\u0432\u0435\u0441\u0442\u043d\u0430\u044f \u043e\u0448\u0438\u0431\u043a\u0430"
private const val TEXT_CHECK_INPUT = "\u041f\u0440\u043e\u0432\u0435\u0440\u044c\u0442\u0435 \u043a\u043e\u0440\u0440\u0435\u043a\u0442\u043d\u043e\u0441\u0442\u044c \u0432\u0432\u0435\u0434\u0435\u043d\u043d\u044b\u0445 \u0434\u0430\u043d\u043d\u044b\u0445"
