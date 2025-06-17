# Delivery Customer Mobile App

A Flutter-based mobile application for customers to order food from restaurants through the delivery platform.

## Features

### Implemented
- **Authentication System**
  - Splash screen with app branding
  - Login with email/password
  - User session management
  - Secure token storage

- **Home Screen**
  - Welcome section with personalized greeting
  - Search functionality
  - Category browsing (Pizza, Burger, Asian, Dessert)
  - Featured restaurants display
  - Bottom navigation with Home, Search, Orders, Profile tabs

- **Core Architecture**
  - Clean architecture with feature-based organization
  - BLoC pattern for state management
  - Service layer for API communication
  - Local storage for offline data
  - Location services integration

### Planned Features (Coming Soon)
- User registration
- Restaurant details and menu browsing
- Shopping cart and checkout
- Order tracking with real-time updates
- User profile management
- Address management
- Order history and reviews
- Push notifications
- Social login (Google)

## Technical Stack

- **Framework**: Flutter 3.10+
- **State Management**: BLoC/Cubit
- **HTTP Client**: Dio
- **Local Storage**: SharedPreferences + FlutterSecureStorage
- **Location**: Geolocator
- **UI**: Material Design 3 with custom theme

## Project Structure

```
lib/
├── core/
│   ├── constants/          # App constants and configuration
│   ├── router/            # Navigation and routing
│   ├── services/          # Core services (API, Storage, Location)
│   └── theme/             # App theming and styling
├── features/
│   ├── auth/              # Authentication feature
│   │   ├── presentation/
│   │   │   ├── bloc/      # Authentication BLoC
│   │   │   ├── pages/     # Login, Splash screens
│   │   │   └── widgets/   # Reusable auth widgets
│   ├── home/              # Home and discovery feature
│   │   └── presentation/
│   │       ├── bloc/      # Home BLoC
│   │       └── pages/     # Home screen
│   ├── cart/              # Shopping cart feature
│   │   └── presentation/
│   │       └── bloc/      # Cart BLoC
│   └── orders/            # Order management feature
│       └── presentation/
│           └── bloc/      # Orders BLoC
└── main.dart              # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK 3.10 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code
- Android/iOS development setup

### Installation

1. Clone the repository
2. Navigate to the mobile_client directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

### Configuration

Update the API base URL in `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'YOUR_API_BASE_URL';
```

## API Integration

The app integrates with the Django backend API with the following endpoints:

- **Authentication**
  - `POST /api/users/login/` - User login
  - `POST /api/users/register/` - User registration
  - `GET /api/users/profile/` - Get user profile

- **Restaurants**
  - `GET /api/restaurants/` - List restaurants
  - `GET /api/restaurants/{id}/` - Restaurant details
  - `GET /api/restaurants/{id}/menu/` - Restaurant menu

- **Orders**
  - `POST /api/orders/` - Create order
  - `GET /api/orders/` - List user orders
  - `GET /api/orders/{id}/` - Order details

- **Search & Promotions**
  - `GET /api/search/` - Search restaurants/dishes
  - `GET /api/promotions/` - Get active promotions

## Design System

The app uses a custom design system based on Material Design 3:

- **Primary Color**: Green (#2E7D32) - representing freshness and food
- **Secondary Color**: Orange (#FF6F00) - representing energy and appetite
- **Typography**: Poppins font family
- **Components**: Custom buttons, text fields, and cards with consistent styling

## Development Status

This is the initial version of the mobile app with core authentication and navigation implemented. The app provides a solid foundation for the complete delivery platform experience.

### Current Limitations
- Mock data for restaurants and categories
- Limited error handling
- No offline functionality yet
- Basic UI without advanced animations

### Next Steps
1. Implement user registration
2. Add restaurant browsing and menu details
3. Build shopping cart functionality
4. Implement order placement and tracking
5. Add user profile management
6. Integrate push notifications
7. Add comprehensive error handling
8. Implement offline support
9. Add unit and integration tests
10. Performance optimization

## Contributing

1. Follow Flutter best practices
2. Use BLoC pattern for state management
3. Maintain clean architecture principles
4. Write meaningful commit messages
5. Test on both Android and iOS devices

## License

This project is part of the delivery platform system.