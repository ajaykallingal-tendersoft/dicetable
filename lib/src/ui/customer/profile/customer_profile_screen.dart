import 'package:dicetable/src/common/custom_text_field.dart';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/login/cubit/google_sign_in_cubit.dart';
import 'package:dicetable/src/ui/customer/profile/bloc/profile_bloc.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerProfileScreen extends StatelessWidget {
  CustomerProfileScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final countryController = TextEditingController();
  final regionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => GoogleSignInCubit()),
      ],
      child: Container(
        height: double.infinity,
        width: double.infinity,
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Profile",
                    style: TextTheme.of(context).labelMedium!.copyWith(
                      color: AppColors.primaryWhiteColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      context.push('/notification');
                    },
                    child: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.primaryWhiteColor,
                          size: 35,
                        ),
                        // if (count > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.appRedColor,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                '8',
                                style: const TextStyle(
                                  color: AppColors.primaryWhiteColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  final profile = state.profile;
                  final readOnly = !state.isEditMode;

                  firstNameController.text = profile.firstName;
                  emailController.text = profile.email;
                  passwordController.text = profile.password;
                  phoneController.text = profile.phone;
                  countryController.text = profile.country;
                  regionController.text = profile.region;

                  return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 20,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Personal Information",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: AppColors.primaryWhiteColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<ProfileBloc>().add(
                                      ToggleEditMode(),
                                    );
                                  },
                                  icon: SvgPicture.asset(
                                    readOnly
                                        ? 'assets/svg/edit-btn.svg'
                                        : 'assets/svg/save-form.svg',
                                  ),
                                  label: Text(
                                    readOnly ? "EDIT" : "SAVE",
                                    style: GoogleFonts.roboto(
                                      color: AppColors.primary,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.h,
                                      vertical: 2.h,
                                    ),
                                    foregroundColor: AppColors.primaryWhiteColor,
                                    side: const BorderSide(
                                      color: AppColors.primaryWhiteColor,
                                    ),
                                    fixedSize: Size(75.w, 26.h),
                                  ),
                                ),
                              ],
                            ),
                            Gap(10),
                            CustomTextField(
                              textFieldAnnotationText: 'First Name',
                              controller: firstNameController,
                              readOnly: readOnly,
                              isPassword: false,
                              isProfile: true,
                              onChanged:
                                  (val) => context.read<ProfileBloc>().add(
                                    UpdateProfileField(field: 'name', value: val),
                                  ),
                              hintText: 'First Name',
                            ),
                            CustomTextField(
                              textFieldAnnotationText: 'Email',
                              controller: emailController,
                              readOnly: readOnly,
                              isPassword: false,
                              isProfile: true,
                              onChanged:
                                  (val) => context.read<ProfileBloc>().add(
                                    UpdateProfileField(
                                      field: 'email',
                                      value: val,
                                    ),
                                  ),
                              hintText: '',
                            ),
                            CustomTextField(
                              textFieldAnnotationText: 'Password',
                              controller: passwordController,
                              readOnly: readOnly,
                              isPassword: true,
                              isProfile: true,
                              onChanged:
                                  (val) => context.read<ProfileBloc>().add(
                                    UpdateProfileField(
                                      field: 'password',
                                      value: val,
                                    ),
                                  ),
                              hintText: 'Password',
                            ),
                            CustomTextField(
                              textFieldAnnotationText: 'Phone',
                              controller: phoneController,
                              readOnly: readOnly,
                              isPassword: false,
                              isProfile: true,
                              onChanged:
                                  (val) => context.read<ProfileBloc>().add(
                                    UpdateProfileField(
                                      field: 'phone',
                                      value: val,
                                    ),
                                  ),
                              hintText: 'Phone',
                            ),
                            CustomTextField(
                              textFieldAnnotationText: 'Country',
                              controller: countryController,
                              readOnly: readOnly,
                              isPassword: false,
                              isProfile: true,
                              onChanged:
                                  (val) => context.read<ProfileBloc>().add(
                                    UpdateProfileField(
                                      field: 'country',
                                      value: val,
                                    ),
                                  ),
                              hintText: 'Country',
                            ),
                            CustomTextField(
                              textFieldAnnotationText: 'Region',
                              controller: regionController,
                              readOnly: readOnly,
                              isPassword: false,
                              isProfile: true,
                              onChanged:
                                  (val) => context.read<ProfileBloc>().add(
                                    UpdateProfileField(
                                      field: 'region',
                                      value: val,
                                    ),
                                  ),
                              hintText: 'Region',
                            ),
                            Gap(20),
                            InkWell(
                              onTap: () {
                                context.read<GoogleSignInCubit>().signOut();
                                ObjectFactory().prefs.setIsCustomerLoggedIn(false);
                                ObjectFactory().prefs.setAuthToken(token: "");
                                ObjectFactory().prefs.setCustomerUserName(customerUserName: "");
                                context.go('/customer_login');
                              },
                              child: ElevatedButtonWidget(
                                height: 70.h,
                                width: double.infinity,
                                iconEnabled: false,
                                iconLabel: 'LOG OUT',
                                color: AppColors.primaryWhiteColor,
                                textColor: AppColors.primary,
                              ),
                            ),
                            Gap(50),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool enabled, {
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
