import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/widgets/auth_text_field.dart';
import '../../../utils/error_handler.dart';
import '../controllers/profile_settings_controller.dart';

class ProfileSettingsPage extends ConsumerStatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  ConsumerState<ProfileSettingsPage> createState() =>
      _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends ConsumerState<ProfileSettingsPage> {
  bool _passwordVisible = false;
  bool _repeatPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<ProfileSettingsState>(profileSettingsControllerProvider, (
      previous,
      next,
    ) {
      if (next.successProfile != null &&
          next.successProfile != previous?.successProfile) {
        AppErrorHandler.showErrorSnackBar(context, 'Обновить данные профиля');
        ref
            .read(profileSettingsControllerProvider.notifier)
            .acknowledgeSuccess();
        if (context.canPop()) {
          context.pop();
        }
      }
    });

    final state = ref.watch(profileSettingsControllerProvider);
    final controller = ref.read(profileSettingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Назад?'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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
                label: 'email',
                placeholder: 'test@gmail.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                errorText: state.emailError,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                value: state.newPassword,
                onChanged: controller.onPasswordChanged,
                label: 'Сменить пароль',
                placeholder: '�������� ����� ��஫�',
                obscureText: !_passwordVisible,
                textInputAction: TextInputAction.next,
                errorText: state.passwordError,
                suffix: TextButton(
                  onPressed: () =>
                      setState(() => _passwordVisible = !_passwordVisible),
                  child: Text(_passwordVisible ? '������' : '��������'),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '...?',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 12),
              AuthTextField(
                value: state.repeatPassword,
                onChanged: controller.onRepeatPasswordChanged,
                label: 'Повторите новый пароль',
                placeholder: 'Повторите пароль',
                obscureText: !_repeatPasswordVisible,
                textInputAction: TextInputAction.next,
                errorText: state.repeatPasswordError,
                suffix: TextButton(
                  onPressed: () => setState(
                    () => _repeatPasswordVisible = !_repeatPasswordVisible,
                  ),
                  child: Text(_repeatPasswordVisible ? '������' : '��������'),
                ),
              ),
              const SizedBox(height: 16),
              AuthTextField(
                value: state.formattedBirthDate,
                onChanged: (_) {},
                label: 'Дата рождения',
                placeholder: 'Вам должно быть больше 18 лет',
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '..?',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (state.generalError != null) ...[
                const SizedBox(height: 16),
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
                      state.isLoading ? 'Загрузка...' : '?..',
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
