import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/Utils/localization.dart';
import 'core/Utils/theme_cubit.dart';
import 'core/router/app_router.dart';
import 'logic/cubits/home/home_cubit.dart';
import 'logic/cubits/navigation/navigation_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  // Create cubit instances
  final localizationCubit = LocalizationCubit();
  final themeCubit = ThemeCubit();
  
  // Load saved preferences
  await localizationCubit.loadSavedLanguage();
  await themeCubit.loadSavedTheme();

  // Setup dependencies
  final appRouter = AppRouter();

  runApp(MyApp(
    localizationCubit: localizationCubit,
    themeCubit: themeCubit,
    appRouter: appRouter,
  ));
}

class MyApp extends StatelessWidget {
  final LocalizationCubit localizationCubit;
  final ThemeCubit themeCubit;
  final AppRouter appRouter;

  const MyApp({
    super.key,
    required this.localizationCubit,
    required this.themeCubit,
    required this.appRouter,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocalizationCubit>.value(
          value: localizationCubit,
        ),
        BlocProvider<ThemeCubit>.value(
          value: themeCubit,
        ),
        BlocProvider<NavigationCubit>(
          create: (context) => NavigationCubit(),
        ),
        BlocProvider<HomeCubit>(
          create: (context) => HomeCubit(),
        ),
      ],
      child: BlocBuilder<LocalizationCubit, LocalizationState>(
        builder: (context, localizationState) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              // Get screen dimensions for dynamic sizing
              final screenHeight = MediaQuery.of(context).size.height;

              return MaterialApp.router(
                title: 'My Lost',
                debugShowCheckedModeBanner: false,
                locale: localizationState.locale,
                supportedLocales: LocalizationCubit.locales.values.toList(),
                theme: ThemeCubit.lightTheme(screenHeight),
                darkTheme: ThemeCubit.darkTheme(screenHeight),
                themeMode: themeState.themeMode == AppThemeMode.dark 
                    ? ThemeMode.dark 
                    : ThemeMode.light,
                routerConfig: appRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}