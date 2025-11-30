import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AppErrorHandler {
  const AppErrorHandler._();

  static String readableMessage(Object error) {
    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        final detail = responseData['detail'];
        if (detail is String && detail.isNotEmpty) {
          return detail;
        }
        final message = responseData['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }

      final statusCode = error.response?.statusCode;
      if (statusCode == 401) {
        return 'Сессия истекла. Авторизуйтесь снова.';
      }
      if (statusCode == 429) {
        return 'Слишком много запросов. Повторите попытку немного позже.';
      }
      if (statusCode != null) {
        return 'Ошибка сервера ($statusCode). Попробуйте позже.';
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Проблемы с сетью. Проверьте подключение к интернету.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Не удалось подключиться к серверу.';
      }
    }

    if (error is FormatException) {
      return error.message;
    }

    final message = error.toString();
    if (message.isEmpty || message == 'Instance of \'Error\'') {
      return 'Произошла неизвестная ошибка. Попробуйте позже.';
    }
    return message;
  }

  static void showErrorSnackBar(BuildContext context, String? message) {
    if (message == null || message.isEmpty) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
  }
}
