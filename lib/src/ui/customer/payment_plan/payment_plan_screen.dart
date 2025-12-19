// lib/src/features/customer/payment_plan/payment_plan_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_bloc.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_event.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_state.dart';

class ChoosePlanScreen extends StatefulWidget {
  const ChoosePlanScreen({super.key});

  @override
  State<ChoosePlanScreen> createState() => _ChoosePlanScreenState();
}

class _ChoosePlanScreenState extends State<ChoosePlanScreen> {
  bool _successDialogShown = false; // Track if success dialog was already shown

  @override
  void initState() {
    super.initState();
    // ✅ CRITICAL: Force fresh initialization for current user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 ChoosePlanScreen: Initializing for current user...');
      context.read<PaymentPlanBloc>()
        ..add(const ResetStateEvent()) // Reset first
        ..add(const InitializePaymentEvent()); // Then initialize fresh
    });
  }

  @override
  void dispose() {
    _successDialogShown = false; // Reset flag on dispose
    super.dispose();
  }

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
            // Reset success dialog flag when a new purchase starts
            if (state.status == PaymentPlanStatus.purchasing) {
              _successDialogShown = false;
              EasyLoading.show(
                status: 'Processing purchase...',
                maskType: EasyLoadingMaskType.black,
              );
            }

            // Handle verification states
            if (state.status == PaymentPlanStatus.verificationFailed) {
              EasyLoading.dismiss();
              final attempts = state.verificationAttempts ?? 0;
              if (attempts == 0) {
                // Max retries reached
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Subscription Issue',
                              style: GoogleFonts.montserrat(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          state.errorMessage?.contains('another account') ==
                                  true
                              ? 'This subscription is already linked to a different account. Please log in with the correct account or purchase a new subscription.'
                              : 'Unable to verify your subscription at this time. Please try again later or contact support if the issue persists.',
                          style: GoogleFonts.montserrat(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                            child: Text(
                              'Close',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                );
              }
            }

            if (state.status == PaymentPlanStatus.needsRestore) {
              EasyLoading.show(
                status: 'Restoring purchases...',
                maskType: EasyLoadingMaskType.black,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Restoring your subscription...',
                    style: GoogleFonts.montserrat(
                      color: AppColors.primaryWhiteColor,
                    ),
                  ),
                  backgroundColor: AppColors.secondary,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            }

            // ✅ FIX: Only show success dialog once using flag
            if (state.status == PaymentPlanStatus.purchaseSuccess &&
                !_successDialogShown) {
              EasyLoading.dismiss();
              _successDialogShown = true; // Set flag to prevent repeated shows

              // ✅ Preference sync now happens automatically in PaymentPlanBloc
              // after successful verification via _syncPaidProfilePreferences()

              context.read<PaymentPlanBloc>().add(
                const CheckSubscriptionStatusEvent(),
              );
              _showSuccessDialog(context, state);
            } else if (state.status == PaymentPlanStatus.purchaseFailed) {
              EasyLoading.dismiss();

              // ✅ FIX: Filter out inappropriate error messages
              final errorMsg = state.errorMessage ?? 'Purchase failed';

              // Don't show snackbar for these expected/handled states
              final shouldSkipSnackbar =
                  errorMsg.contains('already in progress') ||
                  errorMsg.contains('ITEM_ALREADY_OWNED') ||
                  errorMsg.contains('already subscribed') ||
                  errorMsg.contains('Restoring') ||
                  errorMsg.contains('Loading subscription plans');

              if (!shouldSkipSnackbar) {
                _showErrorSnackBar(context, errorMsg);
              }
            } else if (state.status == PaymentPlanStatus.purchaseRestored) {
              EasyLoading.dismiss();
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
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            } else if (state.status == PaymentPlanStatus.cancelled) {
              EasyLoading.dismiss();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Purchase was cancelled',
                    style: GoogleFonts.montserrat(
                      color: AppColors.primaryWhiteColor,
                    ),
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                          context.read<PaymentPlanBloc>()
                            ..add(const ResetStateEvent())
                            ..add(const InitializePaymentEvent());
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

            // ✅ Debug info (remove in production)
            print('📱 ChoosePlanScreen State:');
            print('   User Type: ${state.userType}');
            print('   Is Venue: ${state.isVenueUser}');
            print('   Products: ${state.products.map((p) => p.id).toList()}');

            // Main content
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),

                    // ✅ Show user type for debugging (remove in production)
                    if (kDebugMode)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Debug: ${state.isVenueUser ? "VENUE" : "PUBLIC"} User',
                          style: GoogleFonts.montserrat(
                            color: AppColors.primaryWhiteColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
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

  // Replace your _buildPlanOptions method in ChoosePlanScreen with this fixed version
  // COMPLETE REPLACEMENT for _buildPlanOptions and _buildPlanOption in ChoosePlanScreen

  List<Widget> _buildPlanOptions(BuildContext context, PaymentPlanState state) {
    final widgets = <Widget>[];
    final expandedProducts = state.expandedProducts;

    if (expandedProducts == null || expandedProducts.isEmpty) {
      return widgets;
    }

    // ✅ Sort by raw price (higher first)
    final sortedProducts = List<Map<String, dynamic>>.from(expandedProducts);

    sortedProducts.sort((a, b) {
      final aPrice = (a['rawPrice'] as double?) ?? 0.0;
      final bPrice = (b['rawPrice'] as double?) ?? 0.0;
      return bPrice.compareTo(aPrice); // Descending
    });

    print('📄 Sorted products:');
    for (var item in sortedProducts) {
      final product = item['product'] as ProductDetails;
      final basePlanId = item['basePlanId'] as String?;
      final price = item['formattedPrice'] as String?;
      final billingPeriod = item['billingPeriod'] as String?;
      print('  ${product.id}:$basePlanId - $price ($billingPeriod)');
    }

    for (var expandedProduct in sortedProducts) {
      final product = expandedProduct['product'] as ProductDetails;
      final basePlanId = expandedProduct['basePlanId'] as String?;
      final offerToken = expandedProduct['offerToken'] as String?;
      final formattedPrice = expandedProduct['formattedPrice'] as String?;
      final billingPeriod = expandedProduct['billingPeriod'] as String?;

      final isSelected =
          state.selectedProductId == product.id &&
          (basePlanId == null
              ? state.selectedBasePlanId == null
              : state.selectedBasePlanId == basePlanId);

      widgets.add(
        _buildPlanOption(
          context,
          product: product,
          basePlanId: basePlanId,
          billingPeriod: billingPeriod,
          offerToken: offerToken,
          formattedPrice: formattedPrice,
          isSelected: isSelected,
          onTap: () {
            print('👆 Selected plan:');
            print('   Product: ${product.id}');
            print('   Base Plan: $basePlanId');
            print('   Offer Token: $offerToken');
            print('   Price: $formattedPrice');

            context.read<PaymentPlanBloc>().add(
              SelectPlanEvent(
                product.id,
                basePlanId: basePlanId,
                offerToken: offerToken,
              ),
            );
          },
        ),
      );
      widgets.add(const SizedBox(height: 16.0));
    }

    return widgets;
  }

  // ✅ SIMPLIFIED _buildPlanOption - uses stored billing period
  Widget _buildPlanOption(
    BuildContext context, {
    required ProductDetails product,
    required String? basePlanId,
    required String? billingPeriod,
    required String? offerToken,
    required String? formattedPrice,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const Color selectedColor = AppColors.signUpContainerColor;
    const Color unselectedColor = Colors.transparent;

    final Color borderColor =
        isSelected
            ? selectedColor
            : AppColors.primaryWhiteColor.withOpacity(0.3);

    // ✅ Use stored formatted price
    String displayPrice = formattedPrice ?? product.price;

    // ✅ Parse billing period from stored value
    String period = '';
    String planName = '';
    String? assetPath;

    if (billingPeriod != null && billingPeriod.isNotEmpty) {
      // Parse ISO 8601 duration (e.g., "P1Y", "P1M")
      if (billingPeriod.contains('Y')) {
        period = 'Year';
        planName = 'Yearly plan';
        assetPath = Assets.CALENDAR;
      } else if (billingPeriod.contains('M')) {
        final monthMatch = RegExp(r'P(\d+)M').firstMatch(billingPeriod);
        if (monthMatch != null) {
          final months = int.parse(monthMatch.group(1)!);
          if (months >= 12) {
            period = 'Year';
            planName = 'Yearly plan';
            assetPath = Assets.CALENDAR;
          } else if (months == 1) {
            period = 'Month';
            planName = 'Monthly plan';
            assetPath = Assets.CLOCK_YEARLY;
          } else {
            period = '$months Months';
            planName = '$months Months plan';
            assetPath = Assets.CLOCK_YEARLY;
          }
        } else {
          period = 'Month';
          planName = 'Monthly plan';
          assetPath = Assets.CLOCK_YEARLY;
        }
      } else if (billingPeriod.contains('W')) {
        period = 'Week';
        planName = 'Weekly plan';
        assetPath = Assets.CLOCK_YEARLY;
      } else if (billingPeriod.contains('D')) {
        period = 'Day';
        planName = 'Daily plan';
        assetPath = Assets.CLOCK_YEARLY;
      }
    } else if (basePlanId != null) {
      // Fallback: Use base plan ID
      final basePlanLower = basePlanId.toLowerCase();
      if (basePlanLower.contains('month')) {
        period = 'Month';
        planName = 'Monthly plan';
        assetPath = Assets.CLOCK_YEARLY;
      } else if (basePlanLower.contains('year')) {
        period = 'Year';
        planName = 'Yearly plan';
        assetPath = Assets.CALENDAR;
      }
    }

    final productPriceText =
        period.isNotEmpty ? "$displayPrice / $period" : "$displayPrice";

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
              Expanded(
                child: Row(
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
                    Expanded(
                      child: Text(
                        productPriceText,
                        style: GoogleFonts.montserrat(
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.primaryWhiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (assetPath != null)
                Image.asset(
                  assetPath,
                  height: 24.0,
                  width: 24.0,
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

    final isRetrying =
        state.status == PaymentPlanStatus.verificationFailed &&
        (state.verificationAttempts ?? 0) > 0;

    final canPurchase = state.selectedProductId != null && !isProcessing;

    String buttonText = 'CONTINUE';
    if (isRetrying) {
      buttonText = 'VERIFYING... (${state.verificationAttempts}/3)';
    } else if (isProcessing) {
      buttonText = 'PROCESSING...';
    }

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
                  buttonText,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
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
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
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
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  dialogContext.pop();
                  context.pop();
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

class PricingHelper {
  /// Extracts formatted price from Google Play pricing phases
  static String extractPrice(List<PricingPhaseWrapper> pricingPhases) {
    if (pricingPhases.isEmpty) return '';

    // Use the first pricing phase (the initial price)
    final firstPhase = pricingPhases.first;
    return firstPhase.formattedPrice;
  }

  /// Determines if a base plan is monthly or yearly based on billing period
  static String determinePeriod(List<PricingPhaseWrapper> pricingPhases) {
    if (pricingPhases.isEmpty) return '';

    final billingPeriod = pricingPhases.first.billingPeriod;

    // Google Play uses ISO 8601 duration format
    // P1M = 1 month, P1Y = 1 year, P3M = 3 months, etc.
    if (billingPeriod.contains('Y')) {
      return 'Year';
    } else if (billingPeriod.contains('M')) {
      // Check if it's multiple months
      final monthMatch = RegExp(r'P(\d+)M').firstMatch(billingPeriod);
      if (monthMatch != null) {
        final months = int.parse(monthMatch.group(1)!);
        if (months >= 12) {
          return 'Year';
        } else if (months == 1) {
          return 'Month';
        } else {
          return '$months Months';
        }
      }
      return 'Month';
    } else if (billingPeriod.contains('W')) {
      return 'Week';
    } else if (billingPeriod.contains('D')) {
      return 'Day';
    }

    return '';
  }

  /// Gets a user-friendly plan name based on billing period
  static String getPlanName(String period) {
    switch (period) {
      case 'Year':
        return 'Yearly plan';
      case 'Month':
        return 'Monthly plan';
      case 'Week':
        return 'Weekly plan';
      case 'Day':
        return 'Daily plan';
      default:
        if (period.contains('Months')) {
          return '$period plan';
        }
        return 'Subscription';
    }
  }

  /// Gets the appropriate asset icon based on period
  static String? getAssetForPeriod(String period) {
    if (period == 'Year') {
      return Assets.CALENDAR;
    } else if (period == 'Month') {
      return Assets.CLOCK_YEARLY;
    }
    return null;
  }
}
