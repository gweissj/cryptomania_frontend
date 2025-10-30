package com.example.kursach.presentation.auth

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
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
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.minimumInteractiveComponentSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
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

@Composable
fun LoginScreen(
    state: LoginUiState,
    onEmailChange: (String) -> Unit,
    onPasswordChange: (String) -> Unit,
    onSubmit: () -> Unit,
    onForgotPassword: () -> Unit,
    onNavigateToRegister: () -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 24.dp)
            .verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Spacer(modifier = Modifier.height(48.dp))
        Text(
            text = "Welcome back",
            style = MaterialTheme.typography.headlineMedium.copy(fontWeight = FontWeight.SemiBold),
        )
        Text(
            text = "We're thrilled to see you again!",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        Spacer(modifier = Modifier.height(8.dp))
        AuthTextField(
            value = state.email,
            onValueChange = onEmailChange,
            label = "E-mail",
            placeholder = "Enter your e-mail",
            keyboardOptions = KeyboardOptions(
                keyboardType = KeyboardType.Email,
                imeAction = ImeAction.Next,
            ),
            error = state.emailError,
        )
        var passwordVisible by remember { mutableStateOf(false) }
        AuthTextField(
            value = state.password,
            onValueChange = onPasswordChange,
            label = "Password",
            placeholder = "Enter your password",
            keyboardOptions = KeyboardOptions(
                keyboardType = KeyboardType.Password,
                imeAction = ImeAction.Done,
            ),
            keyboardActions = KeyboardActions(onDone = { onSubmit() }),
            error = state.passwordError,
            visualTransformation = if (passwordVisible) VisualTransformation.None else PasswordVisualTransformation(),
            trailingIcon = {
                PasswordToggle(
                    isVisible = passwordVisible,
                    onToggle = { passwordVisible = !passwordVisible },
                )
            },
        )
        TextButton(
            onClick = onForgotPassword,
            modifier = Modifier.align(Alignment.End),
        ) {
            Text(text = "Forgot Password?")
        }
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
            Text(text = if (state.isLoading) "Loading..." else "Log in")
        }
        Spacer(modifier = Modifier.height(8.dp))
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = TEXT_NO_ACCOUNT,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            TextButton(onClick = onNavigateToRegister) {
                Text(text = TEXT_REGISTER)
            }
        }
    }
}

@Composable
private fun PasswordToggle(
    isVisible: Boolean,
    onToggle: () -> Unit,
) {
    val label = if (isVisible) TEXT_HIDE else TEXT_SHOW
    TextButton(onClick = onToggle) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelLarge,
            color = MaterialTheme.colorScheme.primary,
        )
    }
}

private const val TEXT_NO_ACCOUNT = "\u041d\u0435\u0442 \u0430\u043a\u043a\u0430\u0443\u043d\u0442\u0430?"
private const val TEXT_REGISTER = "\u0417\u0430\u0440\u0435\u0433\u0438\u0441\u0442\u0440\u0438\u0440\u043e\u0432\u0430\u0442\u044c\u0441\u044f"
private const val TEXT_HIDE = "\u0421\u043a\u0440\u044b\u0442\u044c"
private const val TEXT_SHOW = "\u041f\u043e\u043a\u0430\u0437\u0430\u0442\u044c"
