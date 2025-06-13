class VerifyScreenArguments {
  final String email;
  final String otp;
  final String type;
  final String from;
  final String? expiresAt;
  final int? resendAvailableInSeconds;
  VerifyScreenArguments({required this.email,required this.otp, required this.type,required this.from,this.expiresAt, this.resendAvailableInSeconds});
}