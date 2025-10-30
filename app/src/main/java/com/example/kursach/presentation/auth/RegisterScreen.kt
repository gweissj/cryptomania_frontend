package com.example.kursach.presentation.auth

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.minimumInteractiveComponentSize
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import com.example.kursach.presentation.components.AuthTextField
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RegisterScreen(
    state: RegisterUiState,
    onFirstNameChange: (String) -> Unit,
    onLastNameChange: (String) -> Unit,
    onEmailChange: (String) -> Unit,
    onPasswordChange: (String) -> Unit,
    onRepeatPasswordChange: (String) -> Unit,
    onRegionChange: (String) -> Unit,
    onCityChange: (String) -> Unit,
    onBirthDateSelect: (LocalDate) -> Unit,
    onSupportClick: () -> Unit,
    onSubmit: () -> Unit,
    onNavigateBack: () -> Unit,
) {
    var passwordVisible by remember { mutableStateOf(false) }
    var repeatPasswordVisible by remember { mutableStateOf(false) }
    var showDatePicker by rememberSaveable { mutableStateOf(false) }
    val timeZone = remember { ZoneId.systemDefault() }

    if (showDatePicker) {
        BirthDatePickerDialog(
            state = state,
            timeZone = timeZone,
            onDismiss = { showDatePicker = false },
            onDateSelected = {
                onBirthDateSelect(it)
            },
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 24.dp)
            .verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Spacer(modifier = Modifier.height(48.dp))
        Text(
            text = "Register account",
            style = MaterialTheme.typography.headlineMedium.copy(fontWeight = FontWeight.SemiBold),
        )
        Text(
            text = TEXT_SUPPORT_HINT,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        TextButton(onClick = onSupportClick, modifier = Modifier.align(Alignment.Start)) {
            Text(text = "Click here")
        }
        AuthTextField(
            value = state.firstName,
            onValueChange = onFirstNameChange,
            label = TEXT_FIRST_NAME,
            placeholder = TEXT_ENTER_FIRST_NAME,
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Next),
            error = state.firstNameError,
        )
        AuthTextField(
            value = state.lastName,
            onValueChange = onLastNameChange,
            label = TEXT_LAST_NAME,
            placeholder = TEXT_ENTER_LAST_NAME,
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Next),
            error = state.lastNameError,
        )
        AuthTextField(
            value = state.email,
            onValueChange = onEmailChange,
            label = "E-mail",
            placeholder = "Enter your e-mail",
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email, imeAction = ImeAction.Next),
            error = state.emailError,
        )
        AuthTextField(
            value = state.password,
            onValueChange = onPasswordChange,
            label = "Password",
            placeholder = "Enter your password",
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password, imeAction = ImeAction.Next),
            error = state.passwordError,
            visualTransformation = if (passwordVisible) VisualTransformation.None else PasswordVisualTransformation(),
            trailingIcon = {
                PasswordVisibilityToggle(
                    visible = passwordVisible,
                    onToggle = { passwordVisible = !passwordVisible },
                )
            },
        )
        AuthTextField(
            value = state.repeatPassword,
            onValueChange = onRepeatPasswordChange,
            label = TEXT_REPEAT_PASSWORD,
            placeholder = TEXT_REPEAT_PASSWORD_PLACEHOLDER,
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password, imeAction = ImeAction.Next),
            error = state.repeatPasswordError,
            visualTransformation = if (repeatPasswordVisible) VisualTransformation.None else PasswordVisualTransformation(),
            trailingIcon = {
                PasswordVisibilityToggle(
                    visible = repeatPasswordVisible,
                    onToggle = { repeatPasswordVisible = !repeatPasswordVisible },
                )
            },
        )
        AuthTextField(
            value = state.formattedBirthDate,
            onValueChange = {},
            label = TEXT_BIRTHDATE,
            placeholder = TEXT_BIRTHDATE_PLACEHOLDER,
            error = state.birthDateError,
            readOnly = true,
            onClick = { showDatePicker = true },
        )
        AuthTextField(
            value = state.region,
            onValueChange = onRegionChange,
            label = TEXT_REGION,
            placeholder = TEXT_ENTER_REGION,
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Next),
            error = state.regionError,
        )
        AuthTextField(
            value = state.city,
            onValueChange = onCityChange,
            label = TEXT_CITY,
            placeholder = TEXT_ENTER_CITY,
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
            keyboardActions = KeyboardActions(onDone = { onSubmit() }),
            error = state.cityError,
        )
        if (state.generalError != null) {
            Text(
                text = state.generalError,
                color = MaterialTheme.colorScheme.error,
                style = MaterialTheme.typography.bodyMedium,
            )
        }
        Button(
            onClick = onSubmit,
            modifier = Modifier
                .fillMaxWidth()
                .minimumInteractiveComponentSize(),
            enabled = state.canSubmit && !state.isLoading,
        ) {
            Text(text = if (state.isLoading) "Loading..." else "Register now")
        }
        Spacer(modifier = Modifier.height(8.dp))
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text(
                text = TEXT_ALREADY_HAVE_ACCOUNT,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            TextButton(onClick = onNavigateBack) {
                Text(text = TEXT_BACK_TO_LOGIN)
            }
        }
        Spacer(modifier = Modifier.height(32.dp))
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun BirthDatePickerDialog(
    state: RegisterUiState,
    timeZone: ZoneId,
    onDismiss: () -> Unit,
    onDateSelected: (LocalDate) -> Unit,
) {
    val initialSelectedMillis = state.birthDate?.toEpochMillis(timeZone)
    val initialDisplayedDate = state.birthDate ?: LocalDate.now(timeZone).minusYears(18)
    val initialDisplayedMillis = initialDisplayedDate.toEpochMillis(timeZone)
    val datePickerState = rememberDatePickerState(
        initialSelectedDateMillis = initialSelectedMillis,
        initialDisplayedMonthMillis = initialDisplayedMillis,
    )

    DatePickerDialog(
        onDismissRequest = onDismiss,
        confirmButton = {
            TextButton(
                onClick = {
                    val millis = datePickerState.selectedDateMillis
                    if (millis != null) {
                        val today = LocalDate.now(timeZone)
                        val pickedDate = Instant.ofEpochMilli(millis)
                            .atZone(timeZone)
                            .toLocalDate()
                        val validatedDate = if (pickedDate.isAfter(today)) today else pickedDate
                        onDateSelected(validatedDate)
                    }
                    onDismiss()
                },
            ) {
                Text(text = TEXT_DONE)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text(text = TEXT_CANCEL)
            }
        },
    ) {
        DatePicker(
            state = datePickerState,
            showModeToggle = false,
        )
    }
}

private fun LocalDate.toEpochMillis(zoneId: ZoneId): Long =
    atStartOfDay(zoneId).toInstant().toEpochMilli()

@Composable
private fun PasswordVisibilityToggle(
    visible: Boolean,
    onToggle: () -> Unit,
) {
    val label = if (visible) TEXT_HIDE else TEXT_SHOW
    TextButton(onClick = onToggle) {
        Text(text = label, color = MaterialTheme.colorScheme.primary)
    }
}

private const val TEXT_SUPPORT_HINT =
    "\u0415\u0441\u043b\u0438 \u043d\u0443\u0436\u043d\u0430 \u043f\u043e\u0434\u0434\u0435\u0440\u0436\u043a\u0430 \u2014 \u043d\u0430\u0436\u043c\u0438\u0442\u0435 \u00abClick here\u00bb"
private const val TEXT_FIRST_NAME = "\u0418\u043c\u044f"
private const val TEXT_ENTER_FIRST_NAME = "\u0412\u0432\u0435\u0434\u0438\u0442\u0435 \u0438\u043c\u044f"
private const val TEXT_LAST_NAME = "\u0424\u0430\u043c\u0438\u043b\u0438\u044f"
private const val TEXT_ENTER_LAST_NAME = "\u0412\u0432\u0435\u0434\u0438\u0442\u0435 \u0444\u0430\u043c\u0438\u043b\u0438\u044e"
private const val TEXT_REPEAT_PASSWORD = "\u041f\u043e\u0432\u0442\u043e\u0440\u0438\u0442\u0435 \u043f\u0430\u0440\u043e\u043b\u044c"
private const val TEXT_REPEAT_PASSWORD_PLACEHOLDER =
    "\u0412\u0432\u0435\u0434\u0438\u0442\u0435 \u043f\u0430\u0440\u043e\u043b\u044c \u0451\u0449\u0451 \u0440\u0430\u0437"
private const val TEXT_BIRTHDATE = "\u0414\u0430\u0442\u0430 \u0440\u043e\u0436\u0434\u0435\u043d\u0438\u044f"
private const val TEXT_BIRTHDATE_PLACEHOLDER = "\u0412\u044b\u0431\u0435\u0440\u0438\u0442\u0435 \u0434\u0430\u0442\u0443"
private const val TEXT_REGION = "\u0420\u0435\u0433\u0438\u043e\u043d"
private const val TEXT_ENTER_REGION = "\u0412\u0432\u0435\u0434\u0438\u0442\u0435 \u0440\u0435\u0433\u0438\u043e\u043d"
private const val TEXT_CITY = "\u0413\u043e\u0440\u043e\u0434"
private const val TEXT_ENTER_CITY = "\u0412\u0432\u0435\u0434\u0438\u0442\u0435 \u0433\u043e\u0440\u043e\u0434"
private const val TEXT_ALREADY_HAVE_ACCOUNT = "\u0423\u0436\u0435 \u0435\u0441\u0442\u044c \u0430\u043a\u043a\u0430\u0443\u043d\u0442?"
private const val TEXT_BACK_TO_LOGIN = "\u0412\u0435\u0440\u043d\u0443\u0442\u044c\u0441\u044f \u043a\u043e \u0432\u0445\u043e\u0434\u0443"
private const val TEXT_HIDE = "\u0421\u043a\u0440\u044b\u0442\u044c"
private const val TEXT_SHOW = "\u041f\u043e\u043a\u0430\u0437\u0430\u0442\u044c"
private const val TEXT_DONE = "\u0413\u043e\u0442\u043e\u0432\u043e"
private const val TEXT_CANCEL = "\u041e\u0442\u043c\u0435\u043d\u0430"
