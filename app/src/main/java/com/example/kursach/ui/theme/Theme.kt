package com.example.kursach.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val DarkColorScheme = darkColorScheme(
    primary = BluePrimary,
    onPrimary = Color.White,
    secondary = BlueTertiary,
    onSecondary = Color.Black,
    background = NeutralSurfaceDark,
    surface = NeutralSurfaceDark,
    onSurface = NeutralOnSurfaceDark,
    onBackground = NeutralOnSurfaceDark,
)

private val LightColorScheme = lightColorScheme(
    primary = BluePrimary,
    onPrimary = Color.White,
    secondary = BlueSecondary,
    onSecondary = Color.White,
    tertiary = BlueTertiary,
    background = NeutralSurface,
    surface = Color.White,
    onSurface = NeutralOnSurface,
    onBackground = NeutralOnSurface,
)

@Composable
fun KursachTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit,
) {
    val colorScheme = when {
        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content,
    )
}
