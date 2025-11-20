// lib/src/features/customer/payment_plan/payment_plan_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_bloc.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_event.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_state.dart';

class ChoosePlanScreen extends StatelessWidget {
  const ChoosePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.primaryWhiteColor,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Choose Your Plan',
            style: GoogleFonts.montserrat(
              color: AppColors.primaryWhiteColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.restore,
                color: AppColors.primaryWhiteColor,
              ),
              onPressed: () {
                context.read<PaymentPlanBloc>().add(
                  const RestorePurchasesEvent(),
                );
              },
              tooltip: 'Restore Purchases',
            ),
          ],
        ),
        body: BlocConsumer<PaymentPlanBloc, PaymentPlanState>(
          listener: (context, state) {
            // Handle purchase success
            if (state.status == PaymentPlanStatus.purchaseSuccess) {
              // Refresh subscription status after successful purchase
              context.read<PaymentPlanBloc>().add(
                const CheckSubscriptionStatusEvent(),
              );
              _showSuccessDialog(context, state);
            }
            // Handle purchase failure
            else if (state.status == PaymentPlanStatus.purchaseFailed) {
              _showErrorSnackBar(
                context,
                state.errorMessage ?? 'Purchase failed',
              );
            }
            // Handle purchase restoration
            else if (state.status == PaymentPlanStatus.purchaseRestored) {
              // Refresh subscription status after restore
              context.read<PaymentPlanBloc>().add(
                const CheckSubscriptionStatusEvent(),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '✅ Purchases restored successfully',
                    style: GoogleFonts.montserrat(
                      color: AppColors.primaryWhiteColor,
                    ),
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            // Handle cancellation
            else if (state.status == PaymentPlanStatus.cancelled) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Purchase was cancelled',
                    style: GoogleFonts.montserrat(
                      color: AppColors.primaryWhiteColor,
                    ),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          builder: (context, state) {
            // Show loading indicator
            if (state.status == PaymentPlanStatus.loading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.primaryWhiteColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading plans...',
                      style: GoogleFonts.montserrat(
                        color: AppColors.primaryWhiteColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Show error if no products loaded
            if (state.status == PaymentPlanStatus.purchaseFailed &&
                !state.hasProducts) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.primaryWhiteColor,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage ??
                            'Failed to load subscription plans',
                        style: GoogleFonts.montserrat(
                          color: AppColors.primaryWhiteColor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          context.read<PaymentPlanBloc>().add(
                            LoadProductsEvent(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryWhiteColor,
                          foregroundColor: AppColors.primary,
                        ),
                        child: Text('Retry', style: GoogleFonts.montserrat()),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Main content
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),

                    // Title
                    Text(
                      'Select the Perfect Plan for you',
                      style: GoogleFonts.montserrat(
                        color: AppColors.primaryWhiteColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Features card
                    _buildFeaturesCard(context),
                    const SizedBox(height: 32.0),

                    // Plan options
                    if (state.hasProducts)
                      ..._buildPlanOptions(context, state)
                    else
                      Center(
                        child: Text(
                          'No plans available at the moment',
                          style: GoogleFonts.montserrat(
                            color: AppColors.primaryWhiteColor,
                            fontSize: 16,
                          ),
                        ),
                      ),

                    const SizedBox(height: 40.0),

                    // Continue button
                    _buildContinueButton(context, state),

                    const SizedBox(height: 16.0),

                    // Terms text
                    // _buildTermsText(context),
                    const SizedBox(height: 40.0),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrialInfoCard(PaymentPlanState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: AppColors.secondary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Trial ends in ${state.daysRemainingInTrial} days',
              style: GoogleFonts.montserrat(
                color: AppColors.primaryWhiteColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context) {
    const Color cardColor = AppColors.signUpContainerColor;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Features Include',
            style: GoogleFonts.montserrat(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildFeatureRow(
            Assets.PERSONAL,
            'Personalized Profile',
            'Bio, multiple photos & more details',
          ),
          const SizedBox(height: 12.0),
          _buildFeatureRow(
            Assets.TABLE,
            'Table Preferences',
            'Save your favorite table types',
          ),
          const SizedBox(height: 12.0),
          _buildFeatureRow(
            Assets.BELL,
            'Smart Notifications',
            'Mute/unmute favorite cafés',
          ),
          const SizedBox(height: 12.0),
          _buildFeatureRow(
            Assets.ATTENDEE,
            'View Attendees',
            'See who\'s joining upcoming events',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String imagePath, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          imagePath,
          color: AppColors.primary,
          height: 28.0,
          width: 28.0,
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                subtitle,
                style: GoogleFonts.montserrat(
                  color: AppColors.primary.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPlanOptions(BuildContext context, PaymentPlanState state) {
    final widgets = <Widget>[];

    // 1. Separate yearly and other products
    final yearlyProducts =
        state.products.where((p) => p.id.contains('yearly')).toList();
    final otherProducts =
        state.products.where((p) => !p.id.contains('yearly')).toList();

    // 2. Combine, putting yearly first
    final sortedProducts = [...yearlyProducts, ...otherProducts];

    for (var product in sortedProducts) {
      final isSelected = state.selectedProductId == product.id;

      widgets.add(
        _buildPlanOption(
          context,
          product: product,
          isSelected: isSelected,
          onTap: () {
            context.read<PaymentPlanBloc>().add(SelectPlanEvent(product.id));
          },
        ),
      );
      widgets.add(const SizedBox(height: 16.0));
    }

    return widgets;
  }

  Widget _buildPlanOption(
    BuildContext context, {
    required dynamic product,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const Color selectedColor = AppColors.signUpContainerColor;
    const Color unselectedColor = Colors.transparent;

    final Color borderColor =
        isSelected
            ? selectedColor
            : AppColors.primaryWhiteColor.withOpacity(0.3);

    // Determine icon and period
    String period = '';
    String? assetPath;

    if (product.id.contains('yearly')) {
      // 💡 Use your actual asset path for the yearly plan icon
      assetPath = Assets.CALENDAR;
      period = 'Year';
    } else if (product.id.contains('monthly')) {
      // 💡 Use your actual asset path for the monthly plan icon
      assetPath = Assets.CLOCK_YEARLY;
      period = 'Month';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        height: 80.0,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: borderColor, width: isSelected ? 0 : 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  isSelected
                      ? const Icon(
                        Icons.check_circle,
                        color: AppColors.secondary,
                        size: 24.0,
                      )
                      : const Icon(
                        Icons.radio_button_unchecked,
                        color: AppColors.primaryWhiteColor,
                        size: 24.0,
                      ),
                  const SizedBox(width: 16.0),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.price,
                        style: GoogleFonts.montserrat(
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.primaryWhiteColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (period.isNotEmpty)
                        Text(
                          ' / $period',
                          style: GoogleFonts.montserrat(
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : AppColors.primaryWhiteColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (assetPath != null)
                Image.asset(
                  assetPath,
                  height: 24.0, // Match the original Icon size
                  width: 24.0, // Match the original Icon size
                  color:
                      isSelected
                          ? AppColors.primary
                          : AppColors.primaryWhiteColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, PaymentPlanState state) {
    final isProcessing =
        state.isProcessing ||
        state.status == PaymentPlanStatus.purchasing ||
        state.status == PaymentPlanStatus.verifying;

    final canPurchase = state.selectedProductId != null && !isProcessing;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            canPurchase
                ? () {
                  context.read<PaymentPlanBloc>().add(
                    const PurchaseSelectedPlanEvent(),
                  );
                }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryWhiteColor,
          disabledBackgroundColor: AppColors.primaryWhiteColor.withOpacity(0.5),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
        child:
            isProcessing
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                )
                : Text(
                  'CONTINUE',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary, // Ensure button text color is set
                  ),
                ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, PaymentPlanState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                Text('Success!', style: GoogleFonts.montserrat()),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your subscription has been activated!',
                  style: GoogleFonts.montserrat(fontSize: 16,color: AppColors.primary),
                  
                ),
                const SizedBox(height: 12),
                Text(
                  'Plan: ${state.currentSubscriptionId?.replaceAll('_', ' ').toUpperCase()}',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enjoy all premium features! 🎉',
                  style: GoogleFonts.montserrat(fontSize: 14,color: AppColors.primary),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back
                },
                child: Text(
                  'Continue',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: GoogleFonts.montserrat())),
          ],
        ),
        backgroundColor: AppColors.appRedColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AppColors.primaryWhiteColor,
          onPressed: () {},
        ),
      ),
    );
  }
}
