import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../presentation/splash/splash_screen.dart';
import '../../presentation/dashboard/dashboard_screen.dart';
import '../../presentation/main/main_screen.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../providers/auth_providers.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';

  static final routerProvider = Provider<GoRouter>((ref) {
    final notifier = ref.watch(routerNotifierProvider);

    return GoRouter(
      initialLocation: splash,
      refreshListenable: notifier,
      redirect: notifier.redirect,
      routes: [
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: dashboard,
          builder: (context, state) => const MainScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Route not found: ${state.uri.toString()}'),
        ),
      ),
    );
  });
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authStateProvider);
    
    // We only redirect if we have data (either logged in or not)
    return authState.when(
      data: (data) {
        final isLoggedIn = data.session != null;
        final isLoggingIn = state.matchedLocation == AppRouter.login || 
                           state.matchedLocation == AppRouter.register;
        final isSplashing = state.matchedLocation == AppRouter.splash;
        
        if (isSplashing) {
          return null; // Always show splash screen first
        }

        if (!isLoggedIn) {
          // If not logged in, and not already on login/register, go to login
          if (!isLoggingIn) {
            return AppRouter.login;
          }
        } else {
          // If logged in, and on login/register, go to dashboard
          if (isLoggingIn) {
            return AppRouter.dashboard;
          }
        }
        return null;
      },
      loading: () => null, // Stay on current screen while loading
      error: (_, __) => AppRouter.login, // Go to login on error
    );
  }
}
