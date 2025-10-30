package com.example.kursach

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.example.kursach.presentation.navigation.AppNavHost
import com.example.kursach.presentation.session.SessionViewModel
import com.example.kursach.ui.theme.KursachTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    private val sessionViewModel: SessionViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        val splashScreen = installSplashScreen()
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        splashScreen.setKeepOnScreenCondition {
            sessionViewModel.state.value.isLoading
        }

        setContent {
            KursachTheme {
                AppNavHost(sessionViewModel = sessionViewModel)
            }
        }
    }
}
