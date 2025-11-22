import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_router.dart';
import '../../../features/common/widgets/auth_text_field.dart';
import '../../session/controllers/session_controller.dart';
import '../controllers/login_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginState>(loginControllerProvider, (previous, next) {
      final profile = next.successProfile;
      if (profile != null) {
        ref.read(sessionControllerProvider.notifier).setAuthenticated(profile);
        ref.read(loginControllerProvider.notifier).acknowledgeSuccess();
        if (!mounted) {
          return;
        }
        context.go(AppRoute.home);
      }
    });

    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'С возвращением',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Рады снова вас видеть!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              AuthTextField(
                value: state.email,
                onChanged: controller.onEmailChanged,
                label: 'Электронная почта',
                placeholder: 'Введите электронную почту',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                errorText: state.emailError,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                value: state.password,
                onChanged: controller.onPasswordChanged,
                label: 'Пароль',
                placeholder: 'Введите пароль',
                obscureText: !_passwordVisible,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => controller.submit(),
                errorText: state.passwordError,
                suffix: TextButton(
                  onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                  child: Text(_passwordVisible ? 'Скрыть' : 'Показать'),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Функция будет доступна позже')),
                    );
                  },
                  child: const Text('Забыли пароль?'),
                ),
              ),
              if (state.generalError != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.generalError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: state.canSubmit ? controller.submit : null,
                child: SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Text(state.isLoading ? 'Загрузка...' : 'Войти'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Нет аккаунта?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoute.register),
                    child: const Text('Зарегистрироваться'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
