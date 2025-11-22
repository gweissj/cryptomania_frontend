class AuthTokenResponseDto {
  const AuthTokenResponseDto({
    required this.accessToken,
    required this.tokenType,
  });

  final String accessToken;
  final String tokenType;

  factory AuthTokenResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponseDto(
      accessToken: json['access_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? '',
    );
  }
}

class MessageResponseDto {
  const MessageResponseDto({required this.message});

  final String message;

  factory MessageResponseDto.fromJson(Map<String, dynamic> json) {
    return MessageResponseDto(
      message: json['message'] as String? ?? '',
    );
  }
}

