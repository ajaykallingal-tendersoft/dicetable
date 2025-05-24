import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/sign_up_request.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:dicetable/src/ui/customer/authentication/sign_up/bloc/customer_sign_up_bloc.dart';
import 'package:dicetable/src/ui/customer/authentication/sign_up/widget/required_text_field_widget.dart';
import 'package:dicetable/src/ui/verification/verify_screen_argument.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../model/cafe_owner/auth/signUp/google_sign-up_request.dart';
import '../../../cafe_owner/authentication/sign_up/sign_up_screen_argument.dart';

class CustomerSignUpScreen extends StatefulWidget {
  final SignUpScreenArgument signUpScreenArgument;
  const CustomerSignUpScreen({super.key,required this.signUpScreenArgument});

  @override
  State<CustomerSignUpScreen> createState() => _CustomerSignUpScreenState();
}

class _CustomerSignUpScreenState extends State<CustomerSignUpScreen> {
 late final TextEditingController _nameController ;
 late final TextEditingController _emailController ;
 late final TextEditingController _passwordController ;
  late final TextEditingController _confirmPasswordController ;
  late final TextEditingController _phoneController ;
  late final TextEditingController _countryController ;
  late final TextEditingController _regionController ;
  late final _formKey = GlobalKey<FormState>();
  late final bool isGoogleSignUp;


 @override
 void initState() {
   super.initState();
   isGoogleSignUp = widget.signUpScreenArgument.isGoggleSignUp;

   _nameController = TextEditingController(
     text: isGoogleSignUp ? widget.signUpScreenArgument.displayName : '',
   );

   _emailController = TextEditingController(
     text: isGoogleSignUp ? widget.signUpScreenArgument.email : '',
   );
   _passwordController = TextEditingController();
   _confirmPasswordController = TextEditingController();
   _countryController = TextEditingController();
   _regionController = TextEditingController();
   _phoneController = TextEditingController();

   if (isGoogleSignUp) {
     // Delay until the widget tree is built
     WidgetsBinding.instance.addPostFrameCallback((_) {
       final bloc = context.read<CustomerSignUpBloc>();
       bloc.add(UpdateTextField((state) => state.copyWith(
         name: widget.signUpScreenArgument.displayName,
         email: widget.signUpScreenArgument.email,
       )));
     });
   }
 }


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => CustomerSignUpBloc(authDataProvider: AuthDataProvider()),
      child: BlocConsumer<CustomerSignUpBloc, CustomerSignUpState>(
          listener: (context, state) {

            if (state is CustomerSignUpSuccessState) {
              final response = state.signUpRequestResponse;
              if (response.status == false) {
                if (response.errors != null && response.errors!.isNotEmpty) {
                  final firstErrorField = response.errors!.keys.first;
                  final firstErrorMessage = response.errors![firstErrorField]?.first;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(firstErrorMessage ?? 'Something went wrong'),
                      backgroundColor: AppColors.appRedColor,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } else  if (response.status == true)  {
                ObjectFactory().prefs.setCustomerAuthToken(token: state.signUpRequestResponse.token);
                ObjectFactory().prefs.setCustomerUserName(customerUserName: state.signUpRequestResponse.user!.name);
                ObjectFactory().prefs.setUserId(userId: state.signUpRequestResponse.user!.id.toString());
                ObjectFactory().prefs.setIsGoogle(false);
                context.go('/verify',extra: VerifyScreenArguments(
                  from: "customer",
                  email: state.signUpRequestResponse.user!.email,
                  otp: state.signUpRequestResponse.user!.emailOtp.toString(),
                  type: "register",
                ),);
                Fluttertoast.showToast(
                  backgroundColor: AppColors.primaryWhiteColor,
                  textColor: AppColors.appGreenColor,
                  gravity: ToastGravity.BOTTOM,
                  msg: state.signUpRequestResponse.message!,
                );
              }
            }
            if (state is GoogleSignUpSuccessState) {
              final response = state.googleSignUpRequestResponse;
              if (response.status == false) {
                if (response.errors != null &&
                    response.errors!.isNotEmpty) {
                  final firstErrorField = response.errors!.keys.first;
                  final firstErrorMessage =
                      response.errors![firstErrorField]?.first;
                  Fluttertoast.showToast(
                    backgroundColor: AppColors.primaryWhiteColor,
                    textColor: AppColors.appGreenColor,
                    gravity: ToastGravity.BOTTOM,
                    msg: firstErrorMessage ?? "Something went wrong",
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        firstErrorMessage ?? 'Something went wrong',
                      ),
                      backgroundColor: AppColors.appRedColor,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } else if(response.status == true){
                Fluttertoast.showToast(
                  backgroundColor: AppColors.primaryWhiteColor,
                  textColor: AppColors.appGreenColor,
                  gravity: ToastGravity.BOTTOM,
                  msg: state.googleSignUpRequestResponse.message!,
                );
                ObjectFactory().prefs.setCustomerAuthToken(token: state.googleSignUpRequestResponse.token);
                ObjectFactory().prefs.setUserId(userId: state.googleSignUpRequestResponse.user!.id.toString());
                ObjectFactory().prefs.setCustomerUserName(customerUserName: state.googleSignUpRequestResponse.user!.name);
                ObjectFactory().prefs.setIsGoogle(true);
                ObjectFactory().prefs.setIsCustomerLoggedIn(true);
                context.go('/customer_home');
              }
            }

            if (state is CustomerSignUpErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppColors.appRedColor,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          builder: (context, state) {
          return Scaffold(
            extendBody: true,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: SvgPicture.asset(
                  'assets/svg/back.svg',
                  fit: BoxFit.scaleDown,
                  color: AppColors.primaryWhiteColor,
                ),
                onPressed: () => context.pop(),
              ),

              title: Text(
                'Create Account',
                style: TextTheme.of(context).labelLarge!.copyWith(
                  color: AppColors.primaryWhiteColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
              ),
            ),
            body: SafeArea(
              child: Container(
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary,
                      AppColors.secondary,
                      AppColors.tertiary,
                    ],
                    stops: [0.0, 0.5, 0.75, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Gap(50),
                          RequiredTextField(
                            readOnly: isGoogleSignUp ? true : false,
                            hint: 'Name',
                            isRequired: true,
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Name field is required';
                              }
                            },
                            onChanged: (value) {
                              context.read<CustomerSignUpBloc>().add(
                                UpdateTextField(
                                  (state) => state.copyWith(name: value),
                                ),
                              );
                            },
                          ),
                          Gap(10),
                          RequiredTextField(
                            readOnly: isGoogleSignUp ? true : false,
                            hint: "Email",
                            isRequired: true,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              context.read<CustomerSignUpBloc>().add(
                                UpdateTextField(
                                  (state) => state.copyWith(email: value),
                                ),
                              );
                            },
                          ),
                          Gap(10),
                          RequiredTextField(
                            hint: 'Password',
                            isRequired: true,
                            obscureText: true,
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password field is required';
                              }
                              if (value.length < 6) {
                                return 'Enter a Strong Password';
                              }
                            },
                            onChanged: (value) {
                              context.read<CustomerSignUpBloc>().add(
                                UpdateTextField(
                                  (state) => state.copyWith(password: value),
                                ),
                              );
                            },
                          ),
                          Gap(10),
                          RequiredTextField(
                            hint: 'Confirm Password',
                            isRequired: true,
                            obscureText: true,
                            controller: _confirmPasswordController,
                            validator: (value) {
                              if (value != _passwordController.text ||
                                  value == null ||
                                  value.isEmpty) {
                                return 'Enter the correct password';
                              }
                            },
                            onChanged: (value) {
                              context.read<CustomerSignUpBloc>().add(
                                UpdateTextField(
                                  (state) =>
                                      state.copyWith(confirmPassword: value),
                                ),
                              );
                            },
                          ),
                          Gap(10),
                          RequiredTextField(
                            hint: 'Phone number',
                            isRequired: true,
                            controller: _phoneController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Phone number field is required';
                              }
                            },
                            onChanged: (value) {
                              context.read<CustomerSignUpBloc>().add(
                                UpdateTextField(
                                  (state) => state.copyWith(phone: value),
                                ),
                              );
                            },
                          ),
                          Gap(10),
                          RequiredTextField(
                            hint: 'Country',
                            isRequired: true,
                            controller: _countryController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Country field is required';
                              }
                            },
                            onChanged: (value) {
                              context.read<CustomerSignUpBloc>().add(
                                UpdateTextField(
                                  (state) => state.copyWith(country: value),
                                ),
                              );
                            },
                          ),
                          Gap(10),
                          RequiredTextField(
                            hint: 'Region',
                            isRequired: true,
                            controller: _regionController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Region field is required';
                              }
                            },
                            onChanged: (value) {
                              context.read<CustomerSignUpBloc>().add(
                                UpdateTextField(
                                  (state) => state.copyWith(region: value),
                                ),
                              );
                            },
                          ),
                          Gap(30),
                          BlocBuilder<CustomerSignUpBloc, CustomerSignUpState>(
                            builder: (context, state) {
                              // If the state is loading, show a loading indicator instead of the button
                              if (state is CustomerSignUpLoadingState) {
                                return Center(
                                  child: RefreshProgressIndicator(
                                    color: AppColors.primaryWhiteColor,
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              }

                              return InkWell(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    final name = _nameController.text.trim();
                                    final email = _emailController.text.trim();
                                    final password = _passwordController.text.trim();
                                    final confirmPassword = _confirmPasswordController.text.trim();
                                    final phone = _phoneController.text.trim();
                                    final country = _countryController.text.trim();
                                    final region = _regionController.text.trim();

                                    if (password != confirmPassword) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Passwords do not match'),
                                          backgroundColor: AppColors.appRedColor,
                                        ),
                                      );
                                      return;
                                    }

                                    if (isGoogleSignUp) {
                                      final googleSignUpRequest = GoogleSignUpRequest(
                                        name: name,
                                        email: email,
                                        password: password,
                                        passwordConfirmation: confirmPassword,
                                        country: country,
                                        loginType: 5,
                                        phone: phone,
                                        region: region,
                                      );
                                      context.read<CustomerSignUpBloc>().add(
                                        SubmitGoogleSignUp(signupRequest: googleSignUpRequest),
                                      );
                                    } else {
                                      final signUpRequest = SignUpRequest(
                                        name: name,
                                        email: email,
                                        password: password,
                                        passwordConfirmation: confirmPassword,
                                        country: country,
                                        loginType: 5,
                                        phone: phone,
                                        region: region,
                                      );
                                      context.read<CustomerSignUpBloc>().add(
                                        SubmitSignUp(signupRequest: signUpRequest),
                                      );
                                    }

                                    // if (state is SignUpFormState) {
                                    //   final formState = state;
                                    //
                                    //   if (formState.email.isEmpty ||
                                    //       formState.password.isEmpty) {
                                    //     ScaffoldMessenger.of(
                                    //       context,
                                    //     ).showSnackBar(
                                    //       const SnackBar(
                                    //         content: Text(
                                    //           'Please fill in all required fields',
                                    //         ),
                                    //         backgroundColor:
                                    //             AppColors.appRedColor,
                                    //       ),
                                    //     );
                                    //     return;
                                    //   }
                                    //
                                    //   if (formState.password !=
                                    //       formState.confirmPassword) {
                                    //     ScaffoldMessenger.of(
                                    //       context,
                                    //     ).showSnackBar(
                                    //       const SnackBar(
                                    //         content: Text(
                                    //           'Passwords do not match',
                                    //         ),
                                    //         backgroundColor:
                                    //             AppColors.appRedColor,
                                    //       ),
                                    //     );
                                    //     return;
                                    //   }
                                    //
                                    //   if (isGoogleSignUp) {
                                    //     final googleSignUpRequest =
                                    //     GoogleSignUpRequest(
                                    //           name: _nameController.text,
                                    //           email: _emailController.text,
                                    //           password: formState.password,
                                    //           passwordConfirmation:
                                    //           formState.confirmPassword,
                                    //           country: formState.country,
                                    //           loginType: 5,
                                    //           phone: formState.phone,
                                    //           region: formState.region,
                                    //
                                    //     );
                                    //     context.read<CustomerSignUpBloc>().add(
                                    //       SubmitGoogleSignUp(
                                    //         signupRequest: googleSignUpRequest,
                                    //       ),
                                    //     );
                                    //   } else {
                                    //     final signUpRequest = SignUpRequest(
                                    //     name: formState.name,
                                    //     email: formState.email,
                                    //     password: formState.password,
                                    //     passwordConfirmation:
                                    //     formState.confirmPassword,
                                    //     country: formState.country,
                                    //     loginType: 5,
                                    //     phone: formState.phone,
                                    //     region: formState.region,
                                    //   );
                                    //     context.read<CustomerSignUpBloc>().add(
                                    //       SubmitSignUp(
                                    //         signupRequest: signUpRequest,
                                    //       ),
                                    //     );
                                    //   }
                                    // }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Please provide all the required details to continue!',
                                        ),
                                        backgroundColor: AppColors.appRedColor,
                                      ),
                                    );
                                  }
                                },
                                child: ElevatedButtonWidget(
                                  height: 70.h,
                                  width: double.infinity,
                                  iconEnabled: false,
                                  iconLabel: 'SIGN UP',
                                  color: AppColors.primary,
                                  textColor: AppColors.primaryWhiteColor,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
