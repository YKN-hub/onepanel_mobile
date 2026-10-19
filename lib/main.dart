import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanel_mobile/core/config/app_settings.dart';
import 'package:onepanel_mobile/core/i18n/app_localizations.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/core/services/logger_service.dart';
import 'package:onepanel_mobile/pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日志与本地设置（含界面语言）
  await LoggerService.init();
  final settings = await AppSettings.load();

  runApp(OnePanelApp(settings: settings));
}

class OnePanelApp extends StatelessWidget {
  const OnePanelApp({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSettings>.value(value: settings),
        Provider<ServerService>(create: (_) => ServerService()),
      ],
      child: Consumer<AppSettings>(
        builder: (context, appSettings, _) {
          return MaterialApp(
            title: '1Panel Client',
            debugShowCheckedModeBanner: false,
            // 界面语言：跟随系统或用户指定
            locale: appSettings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: [
              AppLocalizations.delegate,
              ...AppLocalizations.globalDelegates,
            ],
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.blue,
              brightness: Brightness.light,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: true,
              ),
              cardTheme: CardThemeData(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.blue,
              brightness: Brightness.dark,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: true,
              ),
              cardTheme: CardThemeData(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            themeMode: ThemeMode.system,
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}
