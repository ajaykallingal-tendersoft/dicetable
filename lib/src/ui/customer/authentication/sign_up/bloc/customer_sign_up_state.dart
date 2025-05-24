part of 'customer_sign_up_bloc.dart';


abstract class CustomerSignUpState extends Equatable {
  const CustomerSignUpState();

  @override
  List<Object?> get props => [];
}

final class CustomerSignUpInitial extends CustomerSignUpState {}

class CustomerSignUpLoadingState extends CustomerSignUpState {}
class CustomerSignUpSuccessState extends CustomerSignUpState {
final SignUpRequestResponse signUpRequestResponse;
const CustomerSignUpSuccessState({required this.signUpRequestResponse});
  @override
  List<Object?> get props => [signUpRequestResponse];
}
class CustomerSignUpErrorState extends CustomerSignUpState {
  final String errorMessage;
  const CustomerSignUpErrorState({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}

class SignUpFormState extends CustomerSignUpState {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String phone;
  final String country;
  final String region;
  // final String address;
  // final String postalCode;

  const SignUpFormState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.phone = '',
    this.country = '',
    this.region = '',
    // this.address = '',
    // this.postalCode = '',
  });

  SignUpFormState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    String? phone,
    String? country,
    String? region,
    // String? address,
    // String? postalCode,


  }) {
    return SignUpFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      region: region ?? this.region,
      // address: address ?? this.address,
      // postalCode: postalCode ?? this.postalCode,
    );
  }

  @override
  List<Object?> get props => [
    name,
    email,
    password,
    confirmPassword,
    phone,
    country,
    region,
  ];
}

///Google signup
class GoogleSignUpInitial extends CustomerSignUpState {}

class GoogleSignUpLoadingState extends CustomerSignUpState {}

class GoogleSignUpSuccessState extends CustomerSignUpState {
  final GoogleSignUpRequestResponse googleSignUpRequestResponse;
  const GoogleSignUpSuccessState({required this.googleSignUpRequestResponse});
}

class GoogleSignUpErrorState extends CustomerSignUpState {
  final String errorMessage;

  const GoogleSignUpErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}