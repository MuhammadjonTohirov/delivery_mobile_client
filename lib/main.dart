import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/location_service.dart';
import 'core/blocs/language_cubit.dart';
import 'l10n/app_localizations.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/orders/presentation/bloc/orders_bloc.dart';
import 'features/search/presentation/bloc/search_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await StorageService.init();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const DeliveryCustomerApp());
}

class DeliveryCustomerApp extends StatelessWidget {
  const DeliveryCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        Provider<LocationService>(
          create: (_) => LocationService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LanguageCubit>(
            create: (context) => LanguageCubit(),
          ),
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              apiService: context.read<ApiService>(),
            )..add(AuthCheckRequested()),
          ),
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(
              apiService: context.read<ApiService>(),
              locationService: context.read<LocationService>(),
            ),
          ),
          BlocProvider<CartBloc>(
            create: (context) => CartBloc(
              apiService: context.read<ApiService>(),
            ),
          ),
          BlocProvider<OrdersBloc>(
            create: (context) => OrdersBloc(
              apiService: context.read<ApiService>(),
            ),
          ),
          BlocProvider<SearchBloc>(
            create: (context) => SearchBloc(
              apiService: context.read<ApiService>(),
            ),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              apiService: context.read<ApiService>(),
            ),
          ),
        ],
        child: BlocBuilder<LanguageCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              onGenerateRoute: AppRouter.generateRoute,
              home: const SplashPage(),
            );
          },
        ),
      ),
    );
  }
}