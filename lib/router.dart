import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soloseaters/main.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_list_response.dart';
import 'package:soloseaters/src/resources/api_providers/customer/profile_data_provider.dart';
import 'package:soloseaters/src/ui/cafe_owner/attendees/attendees_screen.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/forgot_password/forgot_password_otp_screen.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/forgot_password/forgot_password_screen.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/forgot_password/reset_arguments.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/forgot_password/reset_password_screen.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/login/login_screen.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/sign_up/sign_up_screen.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/sign_up/sign_up_screen_argument.dart';
import 'package:soloseaters/src/ui/cafe_owner/home/attendees_arguments.dart';
import 'package:soloseaters/src/ui/cafe_owner/home/home_screen.dart';
import 'package:soloseaters/src/ui/cafe_owner/notification/notification_screen.dart';
import 'package:soloseaters/src/ui/cafe_owner/profile/bloc/profile_bloc.dart';
import 'package:soloseaters/src/ui/cafe_owner/profile/edit_profile_screen.dart';
import 'package:soloseaters/src/ui/cafe_owner/profile/manage_profile_screen.dart';
import 'package:soloseaters/src/ui/cafe_owner/subscription/subscription_overview_screen.dart';
import 'package:soloseaters/src/ui/cafe_owner/subscription/subscription_prompt_screen.dart';
import 'package:soloseaters/src/ui/category/category_screen.dart';
import 'package:soloseaters/src/ui/customer/attendees/networking_attendees.dart';
import 'package:soloseaters/src/ui/customer/authentication/login/login_screen.dart';
import 'package:soloseaters/src/ui/customer/authentication/sign_up/sign_up_screen.dart';
import 'package:soloseaters/src/ui/customer/cafe_details/cafe_details_screen.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/cafe_list_screen.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/components/cafe_details_arguments.dart';
import 'package:soloseaters/src/ui/customer/favourites/favourites_screen.dart';
import 'package:soloseaters/src/ui/customer/favourites/widget/fav_details_argument.dart';
import 'package:soloseaters/src/ui/customer/history/history_screen.dart';
import 'package:soloseaters/src/ui/customer/home/home_screen.dart';
import 'package:soloseaters/src/ui/customer/payment_plan/payment_plan_screen.dart';
import 'package:soloseaters/src/ui/customer/profile/customer_profile_screen.dart';
import 'package:soloseaters/src/ui/customer/profile/paid_profile_bloc/bloc/paid_profile_bloc.dart';
import 'package:soloseaters/src/ui/customer/profile/paid_profile_bloc/bloc/paid_profile_event.dart';
import 'package:soloseaters/src/ui/customer/profile/paid_profile_screen.dart';
import 'package:soloseaters/src/ui/splash/splash_screen.dart';
import 'package:soloseaters/src/ui/verification/email_verification_screen.dart';
import 'package:soloseaters/src/ui/verification/verify_screen_argument.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    navigatorKey: navigatorKey,
    routes: <GoRoute>[
      GoRoute(
        routes: <GoRoute>[
          ///
          /// Cafe Owner Routes
          GoRoute(
            path: 'category',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: const CategoryScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'login',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: const LoginScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'signup',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: SignUpScreen(
                  signUpScreenArgument: state.extra as SignUpScreenArgument,
                ),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'verify',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: EmailVerificationScreen(
                  verifyScreenArguments: state.extra as VerifyScreenArguments,
                ),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'forgot_password',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: const ForgotPasswordScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'forgot_password_otp',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: ForgotPasswordOtpScreen(
                  resetArguments: state.extra as ResetArguments,
                ),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'reset_password',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: ResetPasswordScreen(
                  resetArguments: state.extra as ResetArguments,
                ),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'home',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: const HomeScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'subscription_prompt',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: const SubscriptionPromptScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'subscription',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: const SubscriptionOverviewScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'profile',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: const ManageProfileScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'edit_profile',
            pageBuilder: (BuildContext context, GoRouterState state) {
              final existingBloc = BlocProvider.of<ProfileBloc>(context);

              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: BlocProvider.value(
                  value: existingBloc, // reuse the same ProfileBloc instance
                  child: EditProfileScreen(
                    profileState:
                        state.extra
                            as ProfileState?, // optional if you still want to prefill
                  ),
                ),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeIn,
                    ),
                    child: child,
                  );
                },
              );
            },
          ),

          /* GoRoute(
            path: 'edit_profile',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: EditProfileScreen(
                  profileState: state.extra as ProfileState,
                ),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),*/
          GoRoute(
            path: 'notification',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: NotificationScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),

          ///
          /// Customer App Routes
          GoRoute(
            path: 'customer_login',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: CustomerLoginScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'customer_signUp',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: CustomerSignUpScreen(
                  signUpScreenArgument: state.extra as SignUpScreenArgument,
                ),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'customer_home',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: CustomerHomeScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'cafe_list',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: CafeListScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'fav',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: FavouritesScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'history',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: HistoryScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'customer_profile',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: CustomerProfileScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'cafe_details',
            pageBuilder: (BuildContext context, GoRouterState state) {
              CafeDetailsArguments? cafeDetailsArgs;
              FavDetailsArguments? favDetailsArgs;

              if (state.extra is CafeDetailsArguments) {
                cafeDetailsArgs = state.extra as CafeDetailsArguments;
              } else if (state.extra is FavDetailsArguments) {
                favDetailsArgs = state.extra as FavDetailsArguments;
              } else {
                throw Exception(
                  'Invalid argument type passed to cafe_details route. Expected CafeDetailsArguments or FavDetailsArguments.',
                );
              }

              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: CafeDetailsScreen(
                  cafeDetailsArguments: cafeDetailsArgs,
                  favDetailsArguments: favDetailsArgs,
                ),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'attendees',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: AttendeesScreen(
                  arguments: state.extra as AttendeesArguments,
                ),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  // Define the offset animation: start from (0, 1) [off the bottom]
                  // and animate to (0, 0) [final position].
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;

                  // Use a curve for a smoother effect (Curves.easeOut is common)
                  const curve = Curves.easeOut;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'networking_attendees',
            pageBuilder: (BuildContext context, GoRouterState state) {
              // Extract the arguments and shouldRefresh flag from the extra Map
              final extraData = state.extra as Map<String, dynamic>;
              final arguments = extraData['arguments'] as CafeDetailsArguments;
              final shouldRefresh =
                  extraData['shouldRefresh'] as bool? ?? false;

              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: NetworkingAttendeesScreen(
                  arguments: arguments,
                  shouldRefresh: shouldRefresh,
                ),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeOut;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'payment_plan',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: ChoosePlanScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeInToLinear,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'paid_profile',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: BlocProvider(
                  create:
                      (_) => PaidProfileBloc(
                        customerProfileDataProvider:
                            CustomerProfileDataProvider(),
                      )..add(
                        GetPaidProfileEvent(),
                      ), // if you have an initial event
                  child: PadiProfileScreen(
                    profileData: state.extra as Map<String, dynamic>,
                  ),
                ),
                transitionDuration: const Duration(milliseconds: 500),
                // ... inside your go_router configuration
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;

                  const curve = Curves.easeInOut;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              );
            },
          ),
        ],
        path: '/',
        builder: (BuildContext context, GoRouterState state) => SplashScreen(),
      ),
    ],
  );

  static GoRouter get router => _router;
}
