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
        AppErrorHandler.showErrorSnackBar(context, 'Данные профиля обновлены');
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
        title: const Text('Настройки профиля'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Обновление данных',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Отредактируйте личные данные и при необходимости смените пароль.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                        placeholder: 'example@mail.com',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        errorText: state.emailError,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Безопасность',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuthTextField(
                        value: state.newPassword,
                        onChanged: controller.onPasswordChanged,
                        label: 'Новый пароль',
                        placeholder: 'Оставьте пустым, чтобы не менять',
                        obscureText: !_passwordVisible,
                        textInputAction: TextInputAction.next,
                        errorText: state.passwordError,
                        suffix: TextButton(
                          onPressed: () => setState(
                            () => _passwordVisible = !_passwordVisible,
                          ),
                          child: Text(_passwordVisible ? 'Скрыть' : 'Показать'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      AuthTextField(
                        value: state.repeatPassword,
                        onChanged: controller.onRepeatPasswordChanged,
                        label: 'Подтвердите пароль',
                        placeholder: 'Повторите новый пароль',
                        obscureText: !_repeatPasswordVisible,
                        textInputAction: TextInputAction.next,
                        errorText: state.repeatPasswordError,
                        suffix: TextButton(
                          onPressed: () => setState(
                            () => _repeatPasswordVisible =
                                !_repeatPasswordVisible,
                          ),
                          child: Text(
                            _repeatPasswordVisible ? 'Скрыть' : 'Показать',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Мы не показываем текущий пароль. Заполните оба поля, если хотите установить новый.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuthTextField(
                        value: state.formattedBirthDate,
                        onChanged: (_) {},
                        label: 'Дата рождения',
                        placeholder: 'Дата указывается при регистрации',
                        readOnly: true,
                        enabled: false,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Изменить дату рождения можно через поддержку.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
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
                      state.isLoading ? 'Загрузка...' : 'Сохранить изменения',
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
