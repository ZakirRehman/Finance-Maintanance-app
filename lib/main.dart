import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // IMPORTANT: You need to replace these with your actual Supabase credentials
  await Supabase.initialize(
    url: 'https://sxcflbpyzxyqaedfoitq.supabase.co',
    anonKey: 'sb_publishable_D2VC_59MOEzeQ5oBes2VIw_KjZ7Cfbl',
  );

  runApp(
    const ProviderScope(
      child: InbisatsApp(),
    ),
  );
}

class InbisatsApp extends ConsumerWidget {
  const InbisatsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(AppRouter.routerProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'INBISATs',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        );
      },
    );
  }
}
