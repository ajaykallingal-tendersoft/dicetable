import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/customer/authentication/sign_up/widget/required_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class CustomerSignUpScreen extends StatefulWidget {
   const CustomerSignUpScreen({super.key});

  @override
  State<CustomerSignUpScreen> createState() => _CustomerSignUpScreenState();
}

class _CustomerSignUpScreenState extends State<CustomerSignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
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
                      hint: 'Name',
                      isRequired: true,
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number field is required';
                        }
                      },
                    ),
                    Gap(10),
                    RequiredTextField(
                      hint: "Email",
                      isRequired: true,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    Gap(10),
                    RequiredTextField(
                      hint: 'Password',
                      isRequired: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password field is required';
                        }
                        if (value.length < 6) return 'Enter a Strong Password';
                      },
                    ),
                    Gap(10),
                    RequiredTextField(
                      hint: 'Confirm Password',
                      isRequired: true,
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value != _passwordController.text || value == null || value.isEmpty) {
                          return 'Enter the correct password';
                        }
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
                    ),
                    Gap(30),
                    InkWell(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          context.go('/customer_home');
                        }else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please provide all the required details to continue!'),
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
