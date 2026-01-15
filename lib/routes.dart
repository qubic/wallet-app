import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/pages/auth/sign_in.dart';
import 'package:qubic_wallet/pages/main/main_screen.dart';
import 'package:qubic_wallet/pages/update/app_update_screen.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/app_update_store.dart';

CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

Page<dynamic> Function(BuildContext, GoRouterState) defaultPageBuilder<T>(
        Widget child) =>
    (BuildContext context, GoRouterState state) {
      return buildPageWithDefaultTransition<T>(
        context: context,
        state: state,
        child: child,
      );
    };

bool isSignedIn() {
  return getIt<ApplicationStore>().isSignedIn;
}

bool needsUpdate() {
  final result = getIt<AppUpdateStore>().shouldShowUpdateScreen;
  appLogger.i('[Routes] needsUpdate() called, result: $result');
  return result;
}

// GoRouter configuration
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: [
    GoRoute(
      path: '/update',
      name: 'update',
      pageBuilder: defaultPageBuilder(const AppUpdateScreen()),
    ),
    GoRoute(
      path: '/signIn',
      name: 'signIn',
      builder: (context, state) => const SignIn(),
      pageBuilder: defaultPageBuilder(const SignIn()),
      redirect: (BuildContext context, GoRouterState state) {
        // Check for update BEFORE auth
        if (needsUpdate()) {
          return '/update';
        }
        return null;
      },
    ),
    GoRoute(
      path: '/signInNoAuth',
      name: 'signInNoAuth',
      builder: (context, state) => SignIn(
          disableLocalAuth: state.pathParameters['disableLocalAuth'] == 'true'),
      pageBuilder: defaultPageBuilder(const SignIn(disableLocalAuth: true)),
      redirect: (BuildContext context, GoRouterState state) {
        // Check for update BEFORE auth
        if (needsUpdate()) {
          return '/update';
        }
        return null;
      },
    ),
    GoRoute(
      path: '/',
      name: 'mainScreen',
      builder: (context, state) => const MainScreen(),
      pageBuilder: defaultPageBuilder(const MainScreen()),
      redirect: (BuildContext context, GoRouterState state) {
        // Check for update FIRST
        if (needsUpdate()) {
          return '/update';
        }
        // Then check auth
        if (!isSignedIn()) {
          return '/signin';
        }
        return null;
      },
    ),
  ],
);
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
