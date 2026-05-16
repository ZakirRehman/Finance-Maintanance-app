import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_providers.dart';
import '../../config/routes/app_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Wait for animation and branding visibility
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    // Manually trigger a redirect check if GoRouter hasn't already
    final auth = ref.read(supabaseClientProvider).auth;
    if (auth.currentUser != null) {
      context.go(AppRouter.dashboard);
    } else {
      context.go(AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.card_giftcard,
                    size: 60,
                    color: AppColors.luxuryGold,
                  );
                },
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.05, 1.05),
                duration: 2000.ms,
                curve: Curves.easeInOut,
              )
              .animate()
              .fade(duration: 800.ms),
              
              const SizedBox(height: 10),
              
              Text(
                'INBISATs',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.luxuryGold,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fade(delay: 500.ms, duration: 1000.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 12),
              
              Text(
                '“Crafting Memories, One Gift at a Time”',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1,
                    ),
              ).animate().fade(delay: 1000.ms, duration: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }
}
