import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_themes.dart';
import 'core/theme/theme_controller.dart';
import 'core/widgets/main_scaffold.dart';
import 'features/analytics/presentation/controllers/analytics_controller.dart';
import 'features/goals/data/datasources/goal_hive_datasource.dart';
import 'features/goals/data/models/goal_model.dart';
import 'features/goals/data/repositories/goal_repository_impl.dart';
import 'features/goals/presentation/controllers/goal_controller.dart';
import 'features/onboarding/data/onboarding_datasource.dart';
import 'features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/transactions/data/datasources/transaction_hive_datasource.dart';
import 'features/transactions/data/models/transaction_model.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/presentation/controllers/transaction_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Hive init ──────────────────────────────────────────────────────
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionModelAdapter()); // typeId: 0
  Hive.registerAdapter(GoalModelAdapter());        // typeId: 1

  // ── Onboarding prefs ───────────────────────────────────────────────
  final prefs = OnboardingDatasource();
  await prefs.init();
  Get.put(prefs, permanent: true);

  // ── Theme ──────────────────────────────────────────────────────────
  final themeCtrl = Get.put(ThemeController(), permanent: true);
  themeCtrl.setTheme(prefs.themeKey);

  // ── Transactions ───────────────────────────────────────────────────
  final txDatasource = TransactionHiveDatasourceImpl();
  final txRepository = TransactionRepositoryImpl(datasource: txDatasource);
  final txCtrl = Get.put(
    TransactionController(repository: txRepository),
    permanent: true,
  );

  // ── Goals ──────────────────────────────────────────────────────────
  final goalDatasource = GoalHiveDatasource();
  final goalRepository = GoalRepositoryImpl(datasource: goalDatasource);
  Get.put(GoalController(repository: goalRepository), permanent: true);

  // ── Analytics (depends on TransactionController) ───────────────────
  Get.put(
    AnalyticsController(txCtrl: txCtrl),
    permanent: true,
  );

  // ── Onboarding controller ──────────────────────────────────────────
  Get.put(OnboardingController(datasource: prefs), permanent: true);

  runApp(MyApp(showOnboarding: !prefs.isOnboardingDone));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({
    super.key,
    required this.showOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'MyKajy',
        debugShowCheckedModeBanner: false,

        theme: AppThemes.fromKey(
          themeCtrl.themeKey,
        ),

        initialRoute: showOnboarding
            ? AppRoutes.onboarding
            : AppRoutes.dashboard,

        getPages: [
          GetPage(
            name: AppRoutes.onboarding,
            page: () => const OnboardingPage(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: AppRoutes.dashboard,
            page: () => const MainScaffold(),
            transition: Transition.fadeIn,
          ),
        ],
      ),
    );
  }
}