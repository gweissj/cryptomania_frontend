package com.example.kursach.presentation.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.kursach.presentation.auth.LoginEffect
import com.example.kursach.presentation.auth.LoginScreen
import com.example.kursach.presentation.auth.LoginViewModel
import com.example.kursach.presentation.auth.RegisterScreen
import com.example.kursach.presentation.auth.RegisterViewModel
import com.example.kursach.presentation.auth.RegisterEffect
import com.example.kursach.presentation.home.HomeScreen
import com.example.kursach.presentation.session.SessionViewModel
import com.example.kursach.presentation.splash.SplashScreen
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@Composable
fun AppNavHost(
    sessionViewModel: SessionViewModel,
    modifier: Modifier = Modifier,
) {
    val navController = rememberNavController()
    val snackbarHostState = remember { SnackbarHostState() }
    val coroutineScope = rememberCoroutineScope()
    val sessionState by sessionViewModel.state.collectAsStateWithLifecycle()

    LaunchedEffect(sessionState.isLoading, sessionState.user) {
        if (!sessionState.isLoading) {
            val targetRoute = if (sessionState.user != null) {
                AppDestination.Home.route
            } else {
                AppDestination.Login.route
            }
            val currentRoute = navController.currentDestination?.route
            if (currentRoute != targetRoute) {
                navController.navigate(targetRoute) {
                    popUpTo(navController.graph.findStartDestination().id) {
                        inclusive = true
                    }
                    launchSingleTop = true
                }
            }
        }
    }

    LaunchedEffect(sessionState.error) {
        val message = sessionState.error
        if (!sessionState.isLoading && message != null) {
            snackbarHostState.showSnackbar(message)
            sessionViewModel.clearError()
        }
    }

    Scaffold(
        modifier = modifier,
        snackbarHost = { SnackbarHost(hostState = snackbarHostState) },
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = AppDestination.Splash.route,
            modifier = Modifier.padding(innerPadding),
        ) {
            composable(AppDestination.Splash.route) {
                SplashScreen()
            }
            composable(AppDestination.Login.route) {
                val viewModel: LoginViewModel = hiltViewModel()
                val uiState by viewModel.uiState.collectAsStateWithLifecycle()

                LaunchedEffect(viewModel) {
                    viewModel.effects.collectLatest { effect ->
                        when (effect) {
                            is LoginEffect.Success -> sessionViewModel.setAuthenticated(effect.profile)
                        }
                    }
                }

                LoginScreen(
                    state = uiState,
                    onEmailChange = viewModel::onEmailChanged,
                    onPasswordChange = viewModel::onPasswordChanged,
                    onSubmit = viewModel::submit,
                    onForgotPassword = {
                        coroutineScope.launch {
                            snackbarHostState.showSnackbar(TEXT_FORGOT_PASSWORD_HINT)
                        }
                    },
                    onNavigateToRegister = {
                        navController.navigate(AppDestination.Register.route)
                    },
                )
            }
            composable(AppDestination.Register.route) {
                val viewModel: RegisterViewModel = hiltViewModel()
                val uiState by viewModel.uiState.collectAsStateWithLifecycle()

                LaunchedEffect(viewModel) {
                    viewModel.effects.collectLatest { effect ->
                        when (effect) {
                            is RegisterEffect.Success -> sessionViewModel.setAuthenticated(effect.profile)
                        }
                    }
                }

                RegisterScreen(
                    state = uiState,
                    onFirstNameChange = viewModel::onFirstNameChanged,
                    onLastNameChange = viewModel::onLastNameChanged,
                    onEmailChange = viewModel::onEmailChanged,
                    onPasswordChange = viewModel::onPasswordChanged,
                    onRepeatPasswordChange = viewModel::onRepeatPasswordChanged,
                    onRegionChange = viewModel::onRegionChanged,
                    onCityChange = viewModel::onCityChanged,
                    onBirthDateSelect = viewModel::onBirthDateSelected,
                    onSupportClick = {
                        coroutineScope.launch {
                            snackbarHostState.showSnackbar(TEXT_SUPPORT_HINT)
                        }
                    },
                    onSubmit = viewModel::submit,
                    onNavigateBack = { navController.popBackStack() },
                )
            }
            composable(AppDestination.Home.route) {
                val user = sessionState.user
                if (user != null) {
                    HomeScreen(
                        profile = user,
                        onLogout = sessionViewModel::logout,
                    )
                }
            }
        }
    }
}

private const val TEXT_FORGOT_PASSWORD_HINT =
    "\u0424\u0443\u043d\u043a\u0446\u0438\u044f \u0431\u0443\u0434\u0435\u0442 \u0434\u043e\u0441\u0442\u0443\u043f\u043d\u0430 \u043f\u043e\u0437\u0436\u0435"
private const val TEXT_SUPPORT_HINT =
    "\u0421\u043a\u043e\u0440\u043e \u0437\u0434\u0435\u0441\u044c \u043f\u043e\u044f\u0432\u0438\u0442\u0441\u044f \u043f\u043e\u0434\u0434\u0435\u0440\u0436\u043a\u0430"
