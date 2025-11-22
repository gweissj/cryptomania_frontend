import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_router.dart';
import '../../common/widgets/auth_text_field.dart';
import '../../session/controllers/session_controller.dart';
import '../controllers/register_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  bool _passwordVisible = false;
  bool _repeatPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<RegisterState>(registerControllerProvider, (previous, next) {
      final profile = next.successProfile;
      if (profile != null) {
        ref.read(sessionControllerProvider.notifier).setAuthenticated(profile);
        ref.read(registerControllerProvider.notifier).acknowledgeSuccess();
        if (!mounted) {
          return;
        }
        context.go(AppRoute.home);
      }
    });

    final state = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);

    Future<void> pickDate() async {
      final now = DateTime.now();
      final initial =
          state.birthDate ?? DateTime(now.year - 18, now.month, now.day);
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(1900),
        lastDate: now,
      );
      if (picked != null) {
        controller.onBirthDateSelected(picked);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание аккаунта'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoute.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              AuthTextField(
                value: state.firstName,
                onChanged: controller.onFirstNameChanged,
                label: 'Имя',
                placeholder: 'Введите имя',
                textInputAction: TextInputAction.next,
                errorText: state.firstNameError,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                value: state.lastName,
                onChanged: controller.onLastNameChanged,
                label: 'Фамилия',
                placeholder: 'Введите фамилию',
                textInputAction: TextInputAction.next,
                errorText: state.lastNameError,
              ),
              const SizedBox(height: 16),
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
                textInputAction: TextInputAction.next,
                errorText: state.passwordError,
                suffix: TextButton(
                  onPressed: () =>
                      setState(() => _passwordVisible = !_passwordVisible),
                  child: Text(_passwordVisible ? 'Скрыть' : 'Показать'),
                ),
              ),
              const SizedBox(height: 16),
              AuthTextField(
                value: state.repeatPassword,
                onChanged: controller.onRepeatPasswordChanged,
                label: 'Повторите пароль',
                placeholder: 'Повторите пароль',
                obscureText: !_repeatPasswordVisible,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => controller.submit(),
                errorText: state.repeatPasswordError,
                suffix: TextButton(
                  onPressed: () => setState(
                    () => _repeatPasswordVisible = !_repeatPasswordVisible,
                  ),
                  child: Text(_repeatPasswordVisible ? 'Скрыть' : 'Показать'),
                ),
              ),
              const SizedBox(height: 16),
              AuthTextField(
                value: state.formattedBirthDate,
                onChanged: (_) {},
                label: 'Дата рождения',
                placeholder: 'Выберите дату рождения',
                readOnly: true,
                onTap: pickDate,
                errorText: state.birthDateError,
              ),
              const SizedBox(height: 16),
              if (state.generalError != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    state.generalError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: state.canSubmit ? controller.submit : null,
                child: SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      state.isLoading ? 'Загрузка...' : 'Создать аккаунт',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
