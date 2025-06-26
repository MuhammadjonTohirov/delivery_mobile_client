import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/language/presentation/pages/language_selection_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/restaurant_details_page.dart';
import '../../features/home/presentation/pages/restaurant_menu_items_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/cart/presentation/pages/checkout_page.dart';
import '../../features/orders/presentation/pages/order_details_page.dart';
import '../../features/orders/presentation/pages/order_tracking_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/addresses_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String languageSelection = '/language-selection';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String restaurantDetails = '/restaurant-details';
  static const String restaurantMenuItems = '/restaurant-menu-items';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String orderDetails = '/order-details';
  static const String orderTracking = '/order-tracking';
  static const String profile = '/profile';
  static const String addresses = '/addresses';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );

      case languageSelection:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => LanguageSelectionPage(
            isInitialSetup: args?['isInitialSetup'] ?? false,
          ),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordPage(),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      case restaurantDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        final restaurantId = args?['restaurantId'] as String?;
        if (restaurantId == null) {
          return _errorRoute('Restaurant ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => RestaurantDetailsPage(restaurantId: restaurantId),
          settings: settings,
        );

      case restaurantMenuItems:
        final args = settings.arguments as Map<String, dynamic>?;
        final restaurantId = args?['restaurantId'] as String?;
        final restaurantName = args?['restaurantName'] as String?;
        final restaurantData = args?['restaurantData'] as Map<String, dynamic>?;
        if (restaurantId == null || restaurantName == null) {
          return _errorRoute('Restaurant ID and name are required');
        }
        return MaterialPageRoute(
          builder: (_) => RestaurantMenuItemsPage(
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            restaurantData: restaurantData,
          ),
          settings: settings,
        );

      case cart:
        return MaterialPageRoute(
          builder: (_) => const CartPage(),
          settings: settings,
        );

      case checkout:
        return MaterialPageRoute(
          builder: (_) => const CheckoutPage(),
          settings: settings,
        );

      case orders:
        return _errorRoute('OrdersPage is not implemented');

      case orderDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        final orderId = args?['orderId'] as String?;
        if (orderId == null) {
          return _errorRoute('Order ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => OrderDetailsPage(orderId: orderId),
          settings: settings,
        );

      case orderTracking:
        final args = settings.arguments as Map<String, dynamic>?;
        final orderId = args?['orderId'] as String?;
        if (orderId == null) {
          return _errorRoute('Order ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => OrderTrackingPage(orderId: orderId),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );

      case addresses:
        return MaterialPageRoute(
          builder: (_) => const AddressesPage(),
          settings: settings,
        );

      case AppRouter.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
          settings: settings,
        );

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(_).pushNamedAndRemoveUntil(
                    home,
                    (route) => false,
                  );
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation helper methods
  static Future<void> pushAndRemoveUntil(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static Future<void> pushReplacement(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> push<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }
}