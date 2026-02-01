import 'package:easy_localization/easy_localization.dart';
import 'package:deenhub/config/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/config/themes/themes.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/settings/domain/utils/app_theme_mode.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();


  static void setAppTheme(
    BuildContext context,
    AppThemeMode themeMode,
  ) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setAppTheme(themeMode);
  }

  static void setAccentColor(
    BuildContext context,
    int accentColor,
  ) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setAccentColor(accentColor);
  }
}

class _MyAppState extends State<MyApp> {
  late AppThemeMode _theme;
  late int _accentColor;

  @override
  void initState() {
    super.initState();
    _theme = AppThemeMode.classic;
    _accentColor = ThemeColors.defaultLightColors.first.value;
  }


  setAppTheme(AppThemeMode themeMode) {
    setState(() {
      _theme = themeMode;
    });
    
    // Update system UI overlay style based on theme
    _updateSystemUIOverlayStyle(themeMode.isDarkTheme(context.isDarkMode));
  }

  setAccentColor(int color) {
    setState(() {
      _accentColor = color;
    });
  }

  void _updateSystemUIOverlayStyle(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = _theme.isDarkTheme(context.isDarkMode);
    
    // Update system UI overlay style whenever the build method is called
    _updateSystemUIOverlayStyle(isDarkTheme);
    
    return MaterialApp.router(
      title: 'DeanHub',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: isDarkTheme
            ? Themes.darkScheme(_accentColor, _theme)
            : Themes.lightScheme(_accentColor, _theme),
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontWeight:
                  states.contains(WidgetState.selected) ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: isDarkTheme 
              ? Themes.darkScheme(_accentColor, _theme).primary
              : Themes.lightScheme(_accentColor, _theme).primary,
          foregroundColor: isDarkTheme ? Colors.white : Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: isDarkTheme 
                ? Themes.darkScheme(_accentColor, _theme).primary
                : Themes.lightScheme(_accentColor, _theme).primary,
            statusBarIconBrightness: isDarkTheme ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDarkTheme ? Brightness.light : Brightness.dark,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
        ),
      ),
      routerConfig: AppRouter.router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        // For edge-to-edge display, keep original MediaQuery insets
        // They'll be handled by each Scaffold individually
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
