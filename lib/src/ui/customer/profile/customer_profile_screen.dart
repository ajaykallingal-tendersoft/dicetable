import 'package:dicetable/src/common/custom_text_field.dart';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/resources/api_providers/customer/profile_data_provider.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/login/cubit/google_sign_in_cubit.dart';
import 'package:dicetable/src/ui/customer/profile/bloc/customer_profile_bloc.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  _CustomerProfileScreenState createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerProfileBloc>().add(FetchLocationEvent());
    context.read<CustomerProfileBloc>().add(GetCustomerProfileEvent());
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    countryController.dispose();
    stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Profile",
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primaryWhiteColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                  ),
                ),
                InkWell(
                  onTap: () => context.push('/notification'),
                  child: Stack(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: AppColors.primaryWhiteColor,
                        size: 25.sp,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.sp),
                          decoration: const BoxDecoration(
                            color: AppColors.appRedColor,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16.sp,
                            minHeight: 16.sp,
                          ),
                          child: Center(
                            child: Text(
                              '8',
                              style: TextStyle(
                                color: AppColors.primaryWhiteColor,
                                fontSize: 12.sp,
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
            child: BlocBuilder<CustomerProfileBloc, CustomerProfileState>(
              builder: (context, state) {
                print('Profile State: isLoading=${state.isLoading}, error=${state.errorMessage}, data=${state.profile.data}, lat=${state.latitude}, lng=${state.longitude}');

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (state.isLoading) {
                    EasyLoading.show();
                  } else {
                    EasyLoading.dismiss();
                  }
                });

                if (state.errorMessage != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    EasyLoading.showError(state.errorMessage!);
                  });
                }

                nameController.text = state.profile.data?.name ?? '';
                emailController.text = state.profile.data?.email ?? '';
                phoneController.text = state.profile.data?.phone ?? '';
                countryController.text = state.profile.data?.country ?? '';
                stateController.text = state.profile.data?.state ?? '';

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 20.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Personal Information",
                                style: GoogleFonts.roboto(
                                  fontSize: 14.sp,
                                  color: AppColors.primaryWhiteColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (state.isEditMode) {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<CustomerProfileBloc>().add(const SaveProfileEvent());
                                    }
                                  } else {
                                    context.read<CustomerProfileBloc>().add(ToggleEditModeEvent());
                                  }
                                },
                                icon: SvgPicture.asset(
                                  state.isEditMode ? 'assets/svg/save-form.svg' : 'assets/svg/edit-btn.svg',
                                  height: 16.sp,
                                ),
                                label: Text(
                                  state.isEditMode ? "SAVE" : "EDIT",
                                  style: GoogleFonts.roboto(
                                    color: AppColors.primary,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                  foregroundColor: AppColors.primaryWhiteColor,
                                  backgroundColor: AppColors.primaryWhiteColor,
                                  side: BorderSide(color: AppColors.primaryWhiteColor, width: 1.sp),
                                  minimumSize: Size(80.w, 30.h),
                                ),
                              ),
                            ],
                          ),
                          Gap(10.h),
                          CustomTextField(
                            textFieldAnnotationText: 'Name',
                            controller: nameController,
                            readOnly: !state.isEditMode,
                            isPassword: false,
                            isProfile: true,
                            onChanged: (val) => context
                                .read<CustomerProfileBloc>()
                                .add(UpdateProfileFieldEvent(field: 'name', value: val)),
                            hintText: 'Name',

                          ),
                          CustomTextField(
                            textFieldAnnotationText: 'Email',
                            controller: emailController,
                            readOnly: !state.isEditMode,
                            isPassword: false,
                            isProfile: true,
                            onChanged: (val) => context
                                .read<CustomerProfileBloc>()
                                .add(UpdateProfileFieldEvent(field: 'email', value: val)),
                            hintText: 'Email',

                          ),
                          CustomTextField(
                            textFieldAnnotationText: 'Phone',
                            controller: phoneController,
                            readOnly: !state.isEditMode,
                            isPassword: false,
                            isProfile: true,
                            onChanged: (val) => context
                                .read<CustomerProfileBloc>()
                                .add(UpdateProfileFieldEvent(field: 'phone', value: val)),
                            hintText: 'Phone',

                          ),
                          CustomTextField(
                            textFieldAnnotationText: 'Country',
                            controller: countryController,
                            readOnly: !state.isEditMode,
                            isPassword: false,
                            isProfile: true,
                            onChanged: (val) => context
                                .read<CustomerProfileBloc>()
                                .add(UpdateProfileFieldEvent(field: 'country', value: val)),
                            hintText: 'Country',

                          ),
                          CustomTextField(
                            textFieldAnnotationText: 'State',
                            controller: stateController,
                            readOnly: !state.isEditMode,
                            isPassword: false,
                            isProfile: true,
                            onChanged: (val) => context
                                .read<CustomerProfileBloc>()
                                .add(UpdateProfileFieldEvent(field: 'state', value: val)),
                            hintText: 'State',

                          ),
                          Gap(20.h),
                          InkWell(
                            onTap: () {
                              context.read<GoogleSignInCubit>().signOut();
                              ObjectFactory().prefs.setIsCustomerLoggedIn(false);
                              ObjectFactory().prefs.setAuthToken(token: "");
                              ObjectFactory().prefs.setCustomerUserName(customerUserName: "");
                              context.go('/customer_login');
                            },
                            child: ElevatedButtonWidget(
                              height: 50.h,
                              width: double.infinity,
                              iconEnabled: false,
                              iconLabel: 'LOG OUT',
                              color: AppColors.primaryWhiteColor,
                              textColor: AppColors.primary,
                            ),
                          ),
                          Gap(50.h),
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
    );
  }
}