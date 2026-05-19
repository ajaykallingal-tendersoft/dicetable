import 'package:badges/badges.dart' as badges;
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/resources/api_providers/customer/history_data_provider.dart';
import 'package:soloseaters/src/ui/cafe_owner/notification/count_controller.dart';
import 'package:soloseaters/src/utils/data/auth_session_manager.dart';
import 'package:soloseaters/src/utils/data/sign_out.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'bloc/history_bloc.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final CounterController controller = Get.find<CounterController>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              HistoryBloc(historyDataProvider: HistoryDataProvider())
                ..add(GetHistoryListEvent()),
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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                // context.read<CardCubit>().fetchCards();
              },
            ),
            SliverAppBar(
              backgroundColor: AppColors.primary,
              expandedHeight: 80.h,
              centerTitle: false,
              titleSpacing: 20,
              pinned: true,
              leadingWidth: 0,
              title: Text(
                "History",
                style: TextTheme.of(context).labelMedium!.copyWith(
                  color: AppColors.primaryWhiteColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
              ),
              actionsPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              actions: [
                InkWell(
                  onTap: () {
                    context.push('/notification');
                  },
                  child: Obx(() {
                    return controller.notificationBadgeAmount.value > 0
                        ? badges.Badge(
                          position: badges.BadgePosition.topEnd(
                            top: 0,
                            end:
                                int.parse(
                                          controller
                                              .notificationBadgeAmount
                                              .value
                                              .toString(),
                                        ) >
                                        99
                                    ? -12
                                    : -2,
                          ),
                          badgeAnimation: badges.BadgeAnimation.slide(),
                          showBadge: true,
                          badgeStyle: badges.BadgeStyle(
                            shape: badges.BadgeShape.circle,
                            borderRadius: BorderRadius.circular(10.r),
                            badgeColor: Colors.red,
                            padding: EdgeInsets.all(4),
                          ),
                          badgeContent: Text(
                            // Logic: If greater than 99, show "99+", otherwise show number
                            int.parse(
                                      controller.notificationBadgeAmount.value
                                          .toString(),
                                    ) >
                                    99
                                ? "99+"
                                : controller.notificationBadgeAmount.value
                                    .toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: AppColors.primaryWhiteColor,
                            size: 27.w,
                          ),
                        )
                        : Icon(
                          Icons.notifications_outlined,
                          color: AppColors.primaryWhiteColor,
                          size: 27.w,
                        );
                  }),
                ),
              ],
              leading: const SizedBox(),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                collapseMode: CollapseMode.parallax,
                stretchModes: const [StretchMode.zoomBackground],
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(bottom: 100.h),
              sliver: SliverToBoxAdapter(
                child: BlocConsumer<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    if (state is HistoryLoaded) {
                      if (state.historyListResponse.data!.isEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          EasyLoading.dismiss();
                        });
                        return Center(
                          child: Text(
                            "No history found",
                            style: TextTheme.of(context).bodyMedium!.copyWith(
                              color: AppColors.primaryWhiteColor,
                              fontSize: 16.sp,
                            ),
                          ),
                        );
                      }
                    }
                    if (state is HistoryLoaded) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        EasyLoading.dismiss();
                      });
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                          bottom: 30,
                        ),
                        itemCount: state.historyListResponse.data!.length,
                        itemBuilder: (context, index) {
                          final entry = state.historyListResponse.data![index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryWhiteColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildHistoryRichText(entry.title!, context),
                                Gap(15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Table Type:",
                                          style: TextTheme.of(
                                            context,
                                          ).bodySmall!.copyWith(
                                            color:
                                                AppColors
                                                    .historyActionSubTextColor,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        Text(
                                          entry.diceTables!.join('\n'),
                                          style: TextTheme.of(
                                            context,
                                          ).bodySmall!.copyWith(
                                            color: AppColors.primaryBlackColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Date/Time:",
                                          textAlign: TextAlign.end,
                                          style: TextTheme.of(
                                            context,
                                          ).bodySmall!.copyWith(
                                            color:
                                                AppColors
                                                    .historyActionSubTextColor,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        Text(
                                          _formatLocalTime(entry.dateTime),
                                          style: TextTheme.of(
                                            context,
                                          ).bodySmall!.copyWith(
                                            color: AppColors.primaryBlackColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else if (state is HistoryError) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        EasyLoading.dismiss();
                      });
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(50.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 60,
                                color: AppColors.primaryWhiteColor,
                              ),
                              Gap(16),
                              Text(
                                'Failed to load history',
                                style: TextStyle(
                                  color: AppColors.primaryWhiteColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Gap(16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<HistoryBloc>().add(GetHistoryListEvent());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryWhiteColor,
                                  foregroundColor: AppColors.primary,
                                ),
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        EasyLoading.show();
                      });
                      return const SizedBox.shrink();
                    }
                  },
                  listener: (context, state) {
                    if (state is HistoryLoaded) {
                      if (state.historyListResponse.message!.contains(
                        "Unauthorized access!",
                      )) {
                        EasyLoading.dismiss();
                        if (AuthSessionManager.consumeRefreshFailureFlag()) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            SignOut().logout(context);
                            ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Your session has expired. Please sign in again.", style: TextStyle(color: AppColors.appRedColor)),
        backgroundColor: AppColors.primaryWhiteColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
                          });
                        }
                      }
                    }
                    if (state is HistoryError) {
                      EasyLoading.dismiss();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage),
                          backgroundColor: AppColors.appRedColor,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats UTC ISO string to device local time
  String _formatLocalTime(String? utcDateTimeStr) {
    if (utcDateTimeStr == null || utcDateTimeStr.trim().isEmpty) {
      return '';
    }

    try {
      // Parse backend UTC timestamp
      final utcDateTime = DateTime.parse(utcDateTimeStr).toUtc();

      // Convert to device local timezone
      final localDateTime = utcDateTime.toLocal();

      // Preserve existing UI format
      return DateFormat('dd MMM, yyyy | hh:mm a').format(localDateTime);
    } catch (e) {
      // Fallback to original value to avoid breaking UI
      return utcDateTimeStr;
    }
  }

  /// Parses the backend title string into a styled RichText matching the design.
  ///
  /// Backend title format:
  ///   "[User Name] Expressed interest in cafe [Cafe Name] at DD-MM-YYYY: HH:MM AM"
  ///   "[User Name] added cafe [Cafe Name] to favourites at DD-MM-YYYY: HH:MM AM"
  ///   "[User Name] Removed [Cafe Name] from favourites at DD-MM-YYYY: HH:MM AM"
  ///   "[User Name] Withdrew interest in cafe [Cafe Name] at DD-MM-YYYY: HH:MM AM"
  ///
  /// Design output:
  ///   "Expressed interest in [CafeName bold]"
  ///   "[CafeName bold] has been added to the favourite list."
  ///   "[CafeName bold] has been removed from favourites."
  ///   "Withdrew interest in [CafeName bold]"
  Widget buildHistoryRichText(String title, BuildContext context) {
    // Strip the trailing timestamp "at DD-MM-YYYY: HH:MM AM/PM" or ISO format from the title.
    final cleanTitle = title
        .replaceAll(RegExp(r'\s+at\s+\d{2}-\d{2}-\d{4}:\s*\d{2}:\d{2}\s*(AM|PM)?', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+at\s+\d{4}-\d{2}-\d{2}.*', caseSensitive: false), '')
        .trim();

    String plainText = ''; // rendered in normal weight
    String boldText = ''; // rendered in primary colour + bold
    bool boldFirst = false; // true when cafe name comes before the plain text

    // ── Pattern 1: "... Expressed interest in cafe [Name]" ──────────────────
    final expressedMatch = RegExp(
      r'Expressed interest in cafe\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(cleanTitle);

    // ── Pattern 2: "... Withdrew interest in cafe [Name]" ───────────────────
    final withdrewMatch = RegExp(
      r'Withdrew interest in cafe\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(cleanTitle);

    // ── Pattern 3: "... added cafe [Name] to favourites" ────────────────────
    final addedMatch = RegExp(
      r'added cafe\s+(.+?)\s+to favourites',
      caseSensitive: false,
    ).firstMatch(cleanTitle);

    // ── Pattern 4: "... Removed [Name] from favourites" ─────────────────────
    final removedMatch = RegExp(
      r'[Rr]emoved\s+(.+?)\s+from favourites',
      caseSensitive: false,
    ).firstMatch(cleanTitle);

    if (expressedMatch != null) {
      plainText = 'Expressed interest in ';
      boldText = expressedMatch.group(1)!.trim();
      boldFirst = false;
    } else if (withdrewMatch != null) {
      plainText = 'Withdrew interest in ';
      boldText = withdrewMatch.group(1)!.trim();
      boldFirst = false;
    } else if (addedMatch != null) {
      boldText = addedMatch.group(1)!.trim();
      plainText = ' has been added to the favourite list.';
      boldFirst = true;
    } else if (removedMatch != null) {
      boldText = removedMatch.group(1)!.trim();
      plainText = ' has been removed from favourites.';
      boldFirst = true;
    } else {
      // Fallback: show the cleaned title as plain text (no bold portion)
      plainText = cleanTitle;
      boldFirst = false;
    }

    final plainStyle = TextTheme.of(context).labelMedium!.copyWith(
      color: AppColors.historyActionTextColor,
      fontWeight: FontWeight.w500,
      fontSize: 14.sp,
    );
    final boldStyle = TextTheme.of(context).labelMedium!.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
      fontSize: 14.sp,
    );

    return Text.rich(
      TextSpan(
        children:
            boldFirst
                ? [
                  if (boldText.isNotEmpty)
                    TextSpan(text: boldText, style: boldStyle),
                  if (plainText.isNotEmpty)
                    TextSpan(text: plainText, style: plainStyle),
                ]
                : [
                  if (plainText.isNotEmpty)
                    TextSpan(text: plainText, style: plainStyle),
                  if (boldText.isNotEmpty)
                    TextSpan(text: boldText, style: boldStyle),
                ],
      ),
    );
  }
}
