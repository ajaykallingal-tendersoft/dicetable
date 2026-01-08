import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_bloc.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_event.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_state.dart';
import 'package:soloseaters/src/purchase/services/purchase_service.dart';
import 'package:soloseaters/src/utils/data/privacy_terms.dart';

// class UpgradePopup extends StatelessWidget {
//   const UpgradePopup({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<PaymentPlanBloc, PaymentPlanState>(
//       listener: (context, state) {
//         if (state.status == PaymentPlanStatus.purchasing) {
//           EasyLoading.show(status: 'Processing purchase...');
//         } else if (state.status == PaymentPlanStatus.verifying) {
//           EasyLoading.show(status: 'Verifying purchase...');
//         } else if (state.status == PaymentPlanStatus.purchaseSuccess) {
//           EasyLoading.dismiss();
//           Fluttertoast.showToast(
//             fontSize: 14.sp,
//             backgroundColor: AppColors.appGreenColor,
//             textColor: AppColors.primaryWhiteColor,
//             gravity: ToastGravity.BOTTOM,
//             msg: 'Subscription activated successfully!',
//           );
//           Navigator.of(context).pop();
//         } else if (state.status == PaymentPlanStatus.purchaseFailed) {
//           EasyLoading.dismiss();
//           Fluttertoast.showToast(
//             fontSize: 14.sp,
//             backgroundColor: AppColors.appRedColor,
//             textColor: AppColors.primaryWhiteColor,
//             gravity: ToastGravity.BOTTOM,
//             msg: state.errorMessage ?? 'Purchase failed. Please try again.',
//           );
//         } else if (state.status == PaymentPlanStatus.cancelled) {
//           EasyLoading.dismiss();
//         }
//       },
//       child: Dialog(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         child: Container(
//           decoration: BoxDecoration(
//             color: AppColors.primaryWhiteColor,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           padding: const EdgeInsets.all(24),
//           child: BlocBuilder<PaymentPlanBloc, PaymentPlanState>(
//             builder: (context, state) {
//               // Find venue yearly product
//               ProductDetails? venueProduct;
//               try {
//                 venueProduct = state.products.firstWhere(
//                   (product) => product.id == PaymentService.venueYearlyProductId,
//                 );
//               } catch (e) {
//                 // Product not found, use first available or null
//                 venueProduct =
//                     state.products.isNotEmpty ? state.products.first : null;
//               }

//               final price = venueProduct?.price ?? '\$99';
//               final isProcessing = state.isProcessing;

//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   // Close Button
//                   Align(
//                     alignment: Alignment.topRight,
//                     child: InkWell(
//                       onTap: () {
//                         if (!isProcessing) {
//                           Navigator.of(context).pop();
//                         }
//                       },
//                       child: const Icon(
//                         Icons.close,
//                         color: AppColors.textPrimaryGrey,
//                         size: 24,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // Main Headline
//                   Text(
//                     'Upgrade now to continue enjoying\nall the features without interruption.',
//                     textAlign: TextAlign.center,
//                     softWrap: true,
//                     style: GoogleFonts.montserrat(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   // Price Display
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.baseline,
//                     textBaseline: TextBaseline.alphabetic,
//                     children: <Widget>[
//                       Text(
//                         price,
//                         style: GoogleFonts.montserrat(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                       Text(
//                         ' /Year',
//                         style: GoogleFonts.montserrat(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.textPrimaryGrey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),

//                   // Subtext
//                   Text(
//                     'Get all the benefits for just $price per year.',
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.montserrat(
//                       fontSize: 12,
//                       color: AppColors.textPrimaryGrey,
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   // Subscribe Button
//                   SizedBox(
//                     width: 151.w,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed:
//                           isProcessing
//                               ? null
//                               : () {
//                                 if (venueProduct != null) {
//                                   // Select and purchase the venue yearly plan
//                                   context.read<PaymentPlanBloc>().add(
//                                     SelectPlanEvent(venueProduct.id),
//                                   );
//                                   context.read<PaymentPlanBloc>().add(
//                                     PurchaseProductEvent(venueProduct.id),
//                                   );
//                                 } else {
//                                   // If products not loaded, try loading them first
//                                   context.read<PaymentPlanBloc>().add(
//                                     const LoadProductsEvent(),
//                                   );
//                                   Fluttertoast.showToast(
//                                     fontSize: 14.sp,
//                                     backgroundColor: AppColors.appRedColor,
//                                     textColor: AppColors.primaryWhiteColor,
//                                     gravity: ToastGravity.BOTTOM,
//                                     msg: 'Loading subscription plans...',
//                                   );
//                                 }
//                               },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             isProcessing
//                                 ? AppColors.textPrimaryGrey
//                                 : AppColors.primary,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(18),
//                         ),
//                         elevation: 5,
//                       ),
//                       child:
//                           isProcessing
//                               ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                     Colors.white,
//                                   ),
//                                 ),
//                               )
//                               : Text(
//                                 'SUBSCRIBE HERE',
//                                 style: GoogleFonts.montserrat(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.primaryWhiteColor,
//                                 ),
//                               ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

class UpgradePopup extends StatelessWidget {
  const UpgradePopup({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentPlanBloc, PaymentPlanState>(
      listener: (context, state) {
        if (state.status == PaymentPlanStatus.purchasing) {
          EasyLoading.show(status: 'Processing purchase...');
        } else if (state.status == PaymentPlanStatus.verifying) {
          // ✅ Covers both receipt refresh AND backend verification
          EasyLoading.show(status: 'Verifying purchase...');
        } else if (state.status == PaymentPlanStatus.verificationFailed) {
          // ✅ CRITICAL FIX: Always dismiss EasyLoader first
          EasyLoading.dismiss();

          final attempts = state.verificationAttempts ?? 0;
          if (attempts > 0) {
            // Still retrying - show retry progress
            EasyLoading.show(status: 'Retrying verification ($attempts/3)...');
          } else {
            // Max retries reached - show error dialog
            showDialog(
              context: context,
              builder:
                  (ctx) => AlertDialog(
                    title: const Text('Verification Issue'),
                    content: Text(
                      state.errorMessage ??
                          'Unable to verify your purchase. Please contact support.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
            );
          }
        } else if (state.status == PaymentPlanStatus.purchaseSuccess) {
          EasyLoading.dismiss();
          Fluttertoast.showToast(
            fontSize: 14.sp,
            backgroundColor: AppColors.appGreenColor,
            textColor: AppColors.primaryWhiteColor,
            gravity: ToastGravity.BOTTOM,
            msg: 'Subscription activated successfully!',
          );
          Navigator.of(context).pop();
        } else if (state.status == PaymentPlanStatus.purchaseFailed) {
          EasyLoading.dismiss();
          Fluttertoast.showToast(
            fontSize: 14.sp,
            backgroundColor: AppColors.appRedColor,
            textColor: AppColors.primaryWhiteColor,
            gravity: ToastGravity.BOTTOM,
            msg: state.errorMessage ?? 'Purchase failed. Please try again.',
          );
        } else if (state.status == PaymentPlanStatus.needsRestore) {
          // ✅ Automatically handle restore
          EasyLoading.show(status: 'Restoring subscription...');
        } else if (state.status == PaymentPlanStatus.purchaseRestored) {
          EasyLoading.dismiss();
          Fluttertoast.showToast(
            fontSize: 14.sp,
            backgroundColor: AppColors.appGreenColor,
            textColor: AppColors.primaryWhiteColor,
            gravity: ToastGravity.BOTTOM,
            msg: 'Subscription restored successfully!',
          );
          Navigator.of(context).pop();
        } else if (state.status == PaymentPlanStatus.cancelled) {
          EasyLoading.dismiss();
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryWhiteColor,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(24),
          child: BlocBuilder<PaymentPlanBloc, PaymentPlanState>(
            builder: (context, state) {
              ProductDetails? venueProduct;
              try {
                venueProduct = state.products.firstWhere(
                  (product) =>
                      product.id == PaymentService.venueYearlyProductId,
                );
              } catch (e) {
                venueProduct =
                    state.products.isNotEmpty ? state.products.first : null;
              }

              final price = venueProduct?.price ?? '\$99';
              final isProcessing = state.isProcessing;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        if (!isProcessing) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Icon(
                        Icons.close,
                        color: AppColors.textPrimaryGrey,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upgrade now to continue enjoying\nall the features without interruption.',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Premium Benefits Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Features Include',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildBenefitItem(
                          'Publish events',
                          Icons.event_available,
                        ),
                        const SizedBox(height: 8),
                        _buildBenefitItem(
                          'Boost venue visibility',
                          Icons.trending_up,
                        ),
                        const SizedBox(height: 8),
                        _buildBenefitItem('View event attendees', Icons.people),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Text(
                        price,
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        ' /Year',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Get all the benefits for just $price per year.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppColors.textPrimaryGrey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ✅ AUTO-RENEWAL DISCLOSURE (Required by Play Store & App Store)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Subscription automatically renews unless canceled at least 24 hours before the end of the current period. You can manage and cancel subscriptions in your account settings.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: AppColors.textPrimaryGrey,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  //TERMS & PRIVACY LINKS (Required by both stores)
                  PrivacyAndTermsText(
                    textColor: AppColors.primary,
                    linkColor: AppColors.secondary,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 151.w,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          isProcessing
                              ? null
                              : () {
                                if (venueProduct != null) {
                                  context.read<PaymentPlanBloc>().add(
                                    SelectPlanEvent(venueProduct.id),
                                  );
                                  context.read<PaymentPlanBloc>().add(
                                    PurchaseProductEvent(venueProduct.id),
                                  );
                                } else {
                                  // ✅ FIX: Don't show error toast, just load products
                                  // The EasyLoading indicator will show loading state
                                  context.read<PaymentPlanBloc>().add(
                                    const LoadProductsEvent(),
                                  );
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isProcessing
                                ? AppColors.textPrimaryGrey
                                : AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 5,
                      ),
                      child:
                          isProcessing
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                'SUBSCRIBE HERE',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryWhiteColor,
                                ),
                              ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
