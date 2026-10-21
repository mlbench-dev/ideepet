import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';
import 'package:idee_pet/app/core/analytics/log_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Future.wait([
      ApplicationBindings().injectDependencies(),
      initializeDateFormatting('pt_BR', null),
    ]);
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }
  await BranchService.init();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: AppColors.primary,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'iDeePet',
      // initialRoute: BiometricRoutes
      //     .guide, // TODO: revert to SplashRoutes.splash after testing
      initialRoute: SplashRoutes.splash,
      getPages: AppPages.routes,
      locale: Locale('pt', 'BR'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorObservers: [
        GetXAnalyticsObserver(),
      ],
    ),
  );
}
