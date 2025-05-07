import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/customer/cafe_list/bloc/cafe_list_bloc.dart';
import 'package:dicetable/src/ui/customer/cafe_list/widget/cafe_list_container_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CafeListBloc(),
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
              title:    Text(
                "Favourite",
                style: TextTheme.of(context).labelMedium!.copyWith(
                  color: AppColors.primaryWhiteColor,
                  fontWeight:  FontWeight.w600,
                  fontSize: 18.sp,
                ),
              ),
              actionsPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
              actions: [InkWell(
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
              ),],
              leading: const SizedBox(),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                collapseMode: CollapseMode.parallax,
                stretchModes: const [
                  StretchMode.zoomBackground,
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<CafeListBloc, CafeState>(
                builder: (context, state) {
                  final favoriteCafes = state.cafes.where((cafe) => cafe.isFavorite).toList();
                  if (favoriteCafes.isEmpty) {
                    return const Center(
                      child: Text("No favorites yet."),
                    );
                  }
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: favoriteCafes.length,
                    itemBuilder: (context, index) {
                      final cafe = favoriteCafes[index];
                      return CafeListCard(
                        cafe: cafe,
                          onFavoriteToggle: () => context.read<CafeListBloc>().add(
                            ToggleFavoriteEvent(state.cafes.indexOf(cafe)), // get original index
                          )
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
