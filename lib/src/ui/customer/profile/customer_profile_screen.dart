import 'package:badges/badges.dart' as badges;
import 'package:soloseaters/src/common/custom_text_field.dart';
import 'package:soloseaters/src/common/elevated_button_widget.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/ui/cafe_owner/notification/count_controller.dart';
import 'package:soloseaters/src/ui/customer/profile/bloc/customer_profile_bloc.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:soloseaters/src/utils/data/sign_out.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/login/cubit/google_sign_in_cubit.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/login/cubit/apple_signin_cubit.dart';

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
  bool _isMounted = false;
  final CounterController controller = Get.find<CounterController>();

  @override
  void initState() {
    super.initState();
    _isMounted = true;
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

  void _updateControllerText(
    TextEditingController controller,
    String? newValue,
  ) {
    final String currentText = controller.text;
    final String newNonNullValue = newValue ?? '';

    if (currentText != newNonNullValue) {
      final TextSelection currentSelection = controller.selection;

      controller.value = controller.value.copyWith(
        text: newNonNullValue,
        selection: TextSelection.collapsed(
          offset: currentSelection.baseOffset.clamp(0, newNonNullValue.length),
        ),
      );
    }
  }

  bool _isValidPhoneNumber(String number) {
    final phoneRegex = RegExp(r'^\d{8,10}$');
    return phoneRegex.hasMatch(number);
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
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
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
                    onTap: () {
                      context.push('/notification');
                    },
                    child: Obx(() {
                      return controller.notificationBadgeAmount.value > 0
                          ? badges.Badge(
                            position: badges.BadgePosition.topEnd(
                              top: 0,
                              end: 0,
                            ),
                            badgeAnimation: badges.BadgeAnimation.slide(),
                            showBadge: true,
                            badgeStyle: badges.BadgeStyle(
                              shape: badges.BadgeShape.circle,
                              borderRadius: BorderRadius.circular(10.r),
                              badgeColor: Colors.red,
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 2.h,
                              ),
                            ),
                            badgeContent: Text(
                              controller.notificationBadgeAmount.value
                                  .toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child:  Icon(
                              Icons.notifications_outlined,
                              color: AppColors.primaryWhiteColor,
                              size: 28.w,
                            ),
                          )
                          :  Icon(
                            Icons.notifications_outlined,
                            color: AppColors.primaryWhiteColor,
                            size: 28.w,
                          );
                    }),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<CustomerProfileBloc, CustomerProfileState>(
                builder: (context, state) {
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

                  if (state.profile.data != null) {
                    _updateControllerText(
                      nameController,
                      state.profile.data?.name,
                    );
                    _updateControllerText(
                      emailController,
                      state.profile.data?.email,
                    );
                    _updateControllerText(
                      phoneController,
                      state.profile.data?.phone,
                    );
                    _updateControllerText(
                      countryController,
                      state.profile.data?.country,
                    );
                    _updateControllerText(
                      stateController,
                      state.profile.data?.state,
                    );
                  }

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 26.w,
                        vertical: 0.h,
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
                                        context.read<CustomerProfileBloc>().add(
                                          const SaveProfileEvent(),
                                        );
                                      }
                                    } else {
                                      context.read<CustomerProfileBloc>().add(
                                        ToggleEditModeEvent(),
                                      );
                                    }
                                  },
                                  icon: SvgPicture.asset(
                                    state.isEditMode
                                        ? 'assets/svg/save-form.svg'
                                        : 'assets/svg/edit-btn.svg',
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 6.h,
                                    ),
                                    foregroundColor:
                                        AppColors.primaryWhiteColor,
                                    backgroundColor:
                                        AppColors.primaryWhiteColor,
                                    side: BorderSide(
                                      color: AppColors.primaryWhiteColor,
                                      width: 1.sp,
                                    ),
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
                              onChanged:
                                  (val) =>
                                      context.read<CustomerProfileBloc>().add(
                                        UpdateProfileFieldEvent(
                                          field: 'name',
                                          value: val,
                                        ),
                                      ),
                              hintText: 'Name',
                            ),
                            CustomTextField(
                              textFieldAnnotationText: 'Email',
                              controller: emailController,
                              readOnly: true,
                              isPassword: false,
                              isProfile: true,
                              onChanged:
                                  (val) =>
                                      context.read<CustomerProfileBloc>().add(
                                        UpdateProfileFieldEvent(
                                          field: 'email',
                                          value: val,
                                        ),
                                      ),
                              hintText: 'Email',
                            ),
                            CustomTextField(
                              isPhoneNumber: true,
                              textFieldAnnotationText: 'Phone',
                              controller: phoneController,
                              readOnly: !state.isEditMode,
                              isPassword: false,
                              isProfile: true,
                              errorText:
                                  phoneController.text.trim().isEmpty
                                      ? null
                                      : (!_isValidPhoneNumber(
                                            phoneController.text.trim(),
                                          )
                                          ? "Please enter a valid phone number"
                                          : null),

                              onChanged:
                                  (val) =>
                                      context.read<CustomerProfileBloc>().add(
                                        UpdateProfileFieldEvent(
                                          field: 'phone',
                                          value: val,
                                        ),
                                      ),
                              hintText: 'Phone',
                            ),
                            CustomTextField(
                              textFieldAnnotationText: 'Country',
                              controller: countryController,
                              readOnly: !state.isEditMode,
                              isPassword: false,
                              isProfile: true,
                              onChanged:
                                  (val) =>
                                      context.read<CustomerProfileBloc>().add(
                                        UpdateProfileFieldEvent(
                                          field: 'country',
                                          value: val,
                                        ),
                                      ),
                              hintText: 'Country',
                            ),
                            CustomTextField(
                              textFieldAnnotationText: 'State',
                              controller: stateController,
                              readOnly: !state.isEditMode,
                              isPassword: false,
                              isProfile: true,
                              onChanged:
                                  (val) =>
                                      context.read<CustomerProfileBloc>().add(
                                        UpdateProfileFieldEvent(
                                          field: 'state',
                                          value: val,
                                        ),
                                      ),
                              hintText: 'State',
                            ),
                            Gap(20.h),
                            InkWell(
                              onTap: () {
                                SignOut().logout(context);
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
                            InkWell(
                              onTap: () {
                                _showDeleteAccountDialog(context);
                              },
                              child: ElevatedButtonWidget(
                                height: 70.h,
                                width: double.infinity,
                                iconEnabled: false,
                                iconLabel: 'DELETE ACCOUNT',
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
                listener: (BuildContext context, CustomerProfileState state) {
                  if (state.profile.status == false) {
                    if (state.profile.message!.contains("Unauthorized")) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        SignOut().logout(context);
                        Fluttertoast.showToast(
                          backgroundColor: AppColors.primaryWhiteColor,
                          textColor: AppColors.appRedColor,
                          gravity: ToastGravity.BOTTOM,
                          msg:
                              "Your session has expired. Please sign in again.",
                              fontSize: 14.sp,
                        );
                      });
                    }
                  }
                  if (state is CustomerProfileDeleteLoading) {
                    EasyLoading.show();
                  }
                  if (state is CustomerProfileDeleteSuccess) {
                    if (state.deleteProfileResponse.status == true) {
                      EasyLoading.dismiss();
                      SignOut().logout(context);
                      _showToast(
                        state.deleteProfileResponse.message.toString(),
                        AppColors.appGreenColor,
                      );
                    } else if (state.deleteProfileResponse.status == false) {
                      _showToast(
                        state.deleteProfileResponse.message.toString(),
                        AppColors.appRedColor,
                      );
                    }
                  } else if (state is CustomerProfileDeleteError) {
                    EasyLoading.dismiss();
                    _showToast(state.errorMessage, AppColors.appRedColor);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showToast(String message, Color textColor) {
    if (!_isMounted) return;

    Fluttertoast.showToast(
      backgroundColor: AppColors.primaryWhiteColor,
      textColor: textColor,
      gravity: ToastGravity.BOTTOM,
      msg: message,
      fontSize: 14.sp,
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                'Are you sure?',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Are you sure you want to delete your account? This action is permanent and cannot be undone. All your data will be erased.",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.textPrimaryGrey,
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => dialogContext.pop(),
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.shadowColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<CustomerProfileBloc>().add(
                      CustomerProfileDeleteEvent(),
                    );
                    ObjectFactory().prefs.setIsCustomerLoggedIn(false);
                    context.read<GoogleSignInCubit>().signOut();
                    context.read<AppleSignInCubit>().signOut();
                    // dialogContext.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.primaryWhiteColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
