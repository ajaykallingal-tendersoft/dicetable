
import 'package:dicetable/router.dart';
import 'package:dicetable/src/constants/app_theme.dart';
import 'package:dicetable/src/resources/api_providers/customer/favourite/favourite_data_provider.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/login/cubit/google_sign_in_cubit.dart';
import 'package:dicetable/src/ui/cafe_owner/home/bloc/card_cubit.dart';
import 'package:dicetable/src/ui/cafe_owner/notification/notification_cubit.dart';
import 'package:dicetable/src/ui/cafe_owner/profile/bloc/profile_bloc.dart';
import 'package:dicetable/src/ui/customer/cafe_list/bloc/cafe_list_bloc.dart';
import 'package:dicetable/src/ui/customer/favourites/bloc/favourite_bloc.dart';
import 'package:dicetable/src/utils/network_connectivity/network_connectivity_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';

class App extends StatelessWidget {

  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NetworkConnectivityBloc>(
          create: (BuildContext context) =>
          NetworkConnectivityBloc()..add(NetworkObserve()),
        ),
        BlocProvider<NotificationCubit>(
          create: (context) => NotificationCubit(),
        ),
        BlocProvider<CardCubit>(
          create: (context) => CardCubit(),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(),
        ),
        BlocProvider(create: (context) => GoogleSignInCubit()),
        BlocProvider(
          create: (context) => FavouriteBloc(favouriteDataProvider: FavouriteDataProvider()),
        ),
        BlocProvider(
          create: (context) => CafeListBloc(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(430, 932),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Dice Table',
            routerDelegate: AppRouter.router.routerDelegate,
            routeInformationProvider:
            AppRouter.router.routeInformationProvider,
            routeInformationParser: AppRouter.router.routeInformationParser,
            theme: AppTheme.lightTheme,
            builder: (context, widget) {
              widget = EasyLoading.init()(context, widget);
            widget =  ResponsiveBreakpoints.builder(
                child: widget!,
                breakpoints: [
                  const Breakpoint(start: 0, end: 450, name: MOBILE),
                  const Breakpoint(start: 451, end: 800, name: TABLET),
                  const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                  const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
                ]
              );
              return widget;
            },
          );
        },
      ),
    );
  }
}

