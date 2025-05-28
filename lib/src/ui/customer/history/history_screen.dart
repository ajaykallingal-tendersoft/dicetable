import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/resources/api_providers/customer/history_data_provider.dart';
import 'package:dicetable/src/ui/customer/cafe_list/bloc/cafe_list_bloc.dart';
import 'package:dicetable/src/ui/customer/history/widget/history_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'bloc/history_bloc.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
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
            SliverPadding(
              padding: EdgeInsets.only(bottom: 100),
              sliver: SliverToBoxAdapter(
                child: BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    // Manage EasyLoading based on state
                    if (state is HistoryLoaded) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        EasyLoading.dismiss();
                      });
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
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
                                          style: TextTheme.of(context)
                                              .bodySmall!
                                              .copyWith(
                                            color: AppColors
                                                .historyActionSubTextColor,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        Text(
                                          entry.diceTables!.join('\n'),
                                          style: TextTheme.of(context)
                                              .bodySmall!
                                              .copyWith(
                                            color:
                                            AppColors.primaryBlackColor,
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
                                          style: TextTheme.of(context)
                                              .bodySmall!
                                              .copyWith(
                                            color: AppColors
                                                .historyActionSubTextColor,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        Text(
                                          entry.dateTime!,
                                          style: TextTheme.of(context)
                                              .bodySmall!
                                              .copyWith(
                                            color:
                                            AppColors.primaryBlackColor,
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
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        EasyLoading.show();
                      });
                      return const SizedBox
                          .shrink();
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

  Widget buildHistoryRichText(String title, BuildContext context) {
    String action = '';
    String cafeName = '';

    // Remove username (first word) and timestamp from the end
    List<String> words = title.split(' ');

    // Find where the timestamp starts (pattern: "at DD-MM-YYYY:")
    int timestampIndex = -1;
    for (int i = 0; i < words.length; i++) {
      if (words[i] == 'at' && i + 1 < words.length &&
          RegExp(r'^\d{2}-\d{2}-\d{4}:$').hasMatch(words[i + 1])) {
        timestampIndex = i;
        break;
      }
    }

    List<String> mainWords = words.sublist(
        1, timestampIndex == -1 ? words.length : timestampIndex);
    String mainContent = mainWords.join(' ');

    if (mainContent.contains('Expressed interest in cafe')) {
      action = 'Expressed interest in';
      cafeName = mainContent.replaceFirst('Expressed interest in cafe ', '');
    }
    else if (mainContent.contains('added cafe') &&
        mainContent.contains('to favourites')) {
      action = 'Added';
      RegExp regex = RegExp(r'added cafe\s+(.+?)\s+to favourites');
      Match? match = regex.firstMatch(mainContent);
      if (match != null) {
        cafeName = '${match.group(1)} to favourites';
      }
    }
    else if (mainContent.contains('removed cafe') &&
        mainContent.contains('from favourites')) {
      action = 'Removed';
      RegExp regex = RegExp(r'removed cafe\s+(.+?)\s+from favourites');
      Match? match = regex.firstMatch(mainContent);
      if (match != null) {
        cafeName = '${match.group(1)} from favourites';
      }
    }
    else {
      if (mainContent.contains('cafe ')) {
        List<String> parts = mainContent.split('cafe ');
        if (parts.length >= 2) {
          action = parts[0].trim();
          cafeName = parts[1].trim();
        }
      } else {
        action = mainContent;
      }
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: "$action ",
            style: TextTheme
                .of(context)
                .labelMedium!
                .copyWith(
              color: AppColors.historyActionTextColor,
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
            ),
          ),
          if (cafeName.isNotEmpty)
            TextSpan(
              text: cafeName,
              style: TextTheme
                  .of(context)
                  .labelMedium!
                  .copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
        ],
      ),
    );
  }

}