package com.example.kursach.presentation.components

import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.onClick
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.input.VisualTransformation

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AuthTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    placeholder: String,
    modifier: Modifier = Modifier,
    error: String? = null,
    singleLine: Boolean = true,
    readOnly: Boolean = false,
    enabled: Boolean = true,
    keyboardOptions: KeyboardOptions = KeyboardOptions.Default,
    keyboardActions: KeyboardActions = KeyboardActions.Default,
    visualTransformation: VisualTransformation = VisualTransformation.None,
    trailingIcon: (@Composable (() -> Unit))? = null,
    onClick: (() -> Unit)? = null,
) {
    val clickInteractionSource = remember { MutableInteractionSource() }
    val baseModifier = modifier.fillMaxWidth()
    val isReadOnly = readOnly || onClick != null
    val changeHandler = if (isReadOnly) {
        {}
    } else {
        onValueChange
    }

    val textFieldContent: @Composable (Modifier) -> Unit = { fieldModifier ->
        OutlinedTextField(
            value = value,
            onValueChange = changeHandler,
            modifier = fieldModifier,
            label = { Text(text = label) },
            placeholder = { Text(text = placeholder) },
            isError = error != null,
            singleLine = singleLine,
            readOnly = isReadOnly,
            enabled = enabled,
            keyboardOptions = keyboardOptions,
            keyboardActions = keyboardActions,
            supportingText = if (error != null) {
                { Text(text = error, color = MaterialTheme.colorScheme.error) }
            } else {
                null
            },
            visualTransformation = visualTransformation,
            trailingIcon = trailingIcon,
        )
    }

    if (onClick != null) {
        Box(modifier = baseModifier) {
            textFieldContent(Modifier.fillMaxWidth())
            Box(
                modifier = Modifier
                    .matchParentSize()
                    .semantics {
                        onClick {
                            onClick()
                            true
                        }
                    }
                    .clickable(
                        enabled = enabled,
                        interactionSource = clickInteractionSource,
                        indication = null,
                        role = Role.Button,
                    ) { onClick() },
            )
        }
    } else {
        textFieldContent(baseModifier)
    }
}
