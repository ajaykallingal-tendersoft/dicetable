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

class UpgradePopup extends StatelessWidget {
  const UpgradePopup({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentPlanBloc, PaymentPlanState>(
      listener: (context, state) {
        if (state.status == PaymentPlanStatus.purchasing) {
          EasyLoading.show(status: 'Processing purchase...');
        } else if (state.status == PaymentPlanStatus.verifying) {
          EasyLoading.show(status: 'Verifying purchase...');
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
              // Find venue yearly product
              ProductDetails? venueProduct;
              try {
                venueProduct = state.products.firstWhere(
                  (product) => product.id == PaymentService.venueYearlyId,
                );
              } catch (e) {
                // Product not found, use first available or null
                venueProduct = state.products.isNotEmpty ? state.products.first : null;
              }
              
              final price = venueProduct?.price ?? '\$99';
              final isProcessing = state.isProcessing;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Close Button
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

                  // Main Headline
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
                  const SizedBox(height: 30),

                  // Price Display
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

                  // Subtext
                  Text(
                    'Get all the benefits for just $price per year.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppColors.textPrimaryGrey,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Subscribe Button
                  SizedBox(
                    width: 151.w,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : () {
                        if (venueProduct != null) {
                          // Select and purchase the venue yearly plan
                          context.read<PaymentPlanBloc>().add(
                            SelectPlanEvent(venueProduct.id),
                          );
                          context.read<PaymentPlanBloc>().add(
                            PurchaseProductEvent(venueProduct.id),
                          );
                        } else {
                          // If products not loaded, try loading them first
                          context.read<PaymentPlanBloc>().add(
                            const LoadProductsEvent(),
                          );
                          Fluttertoast.showToast(
                            fontSize: 14.sp,
                            backgroundColor: AppColors.appRedColor,
                            textColor: AppColors.primaryWhiteColor,
                            gravity: ToastGravity.BOTTOM,
                            msg: 'Loading subscription plans...',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isProcessing 
                            ? AppColors.textPrimaryGrey 
                            : AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 5,
                      ),
                      child: isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
}