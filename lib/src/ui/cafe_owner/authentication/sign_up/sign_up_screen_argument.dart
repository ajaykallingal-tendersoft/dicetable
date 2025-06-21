class SignUpScreenArgument {
  final bool? isGoggleSignUp;
  final bool? isAppleSignUp;
  final String email;
  final String displayName;
  final String phone;
  final String imageBase64;
  SignUpScreenArgument({this.isGoggleSignUp,required this.email,required this.displayName,required this.phone, required this.imageBase64,this.isAppleSignUp});
}