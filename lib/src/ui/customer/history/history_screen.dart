import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/customer/cafe_list/bloc/cafe_list_bloc.dart';
import 'package:dicetable/src/ui/customer/history/widget/history_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'bloc/history_bloc.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryBloc()..add(LoadHistoryEvent()),
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
              backgroundColor: Colors.transparent,
              expandedHeight: 100.h,
              centerTitle: false,
              titleSpacing: 20,
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
              leading: const SizedBox(),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                collapseMode: CollapseMode.parallax,
                stretchModes: const [StretchMode.zoomBackground],
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<HistoryBloc, HistoryState>(
                builder: (context, state) {
                  if (state is HistoryLoaded) {
                    return ListView.builder(
                      shrinkWrap: true,
                      // Add this line
                      physics: const NeverScrollableScrollPhysics(),
                      // To disable scrolling of the inner ListView
                      padding: const EdgeInsets.all(16),
                      itemCount: state.history.length,
                      itemBuilder: (context, index) {
                        final entry = state.history[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: entry.action + " ",
                                      style: TextTheme.of(
                                        context,
                                      ).labelMedium!.copyWith(
                                        color: AppColors.historyActionTextColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    TextSpan(
                                      text: entry.cafeName,
                                      style: TextTheme.of(
                                        context,
                                      ).labelMedium!.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Gap(15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                        entry.tableType,
                                        style: TextTheme.of(
                                          context,
                                        ).bodySmall!.copyWith(
                                          color:
                                              AppColors
                                                  .primaryBlackColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                        _formatDateTime(entry.dateTime),
                                        style: TextTheme.of(
                                          context,
                                        ).bodySmall!.copyWith(
                                          color:
                                              AppColors
                                                  .primaryBlackColor,
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
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${_pad(dateTime.day)} ${_monthName(dateTime.month)}, ${dateTime.year} | ${_pad(dateTime.hour)}:${_pad(dateTime.minute)} PM";
  }

  String _pad(int value) => value.toString().padLeft(2, '0');

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }
}
