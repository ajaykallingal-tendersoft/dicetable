class ResetArguments {
  final String email;
  final String token;
  final String? expiresAt;
  final int? resendAvailableInSeconds;

  ResetArguments({required this.email,required this.token, this.expiresAt, this.resendAvailableInSeconds});
}