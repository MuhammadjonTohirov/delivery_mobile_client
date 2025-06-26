import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  // App Name
  String get appName;
  
  // Common
  String get ok;
  String get cancel;
  String get yes;
  String get no;
  String get loading;
  String get error;
  String get success;
  String get retry;
  String get save;
  String get edit;
  String get delete;
  String get back;
  String get next;
  String get done;
  String get search;
  String get filter;
  String get sort;
  String get clear;
  String get apply;
  String get close;
  
  // Authentication
  String get signIn;
  String get signUp;
  String get signOut;
  String get logout;
  String get email;
  String get password;
  String get confirmPassword;
  String get fullName;
  String get firstName;
  String get lastName;
  String get phoneNumber;
  String get phoneOptional;
  String get forgotPassword;
  String get createAccount;
  String get alreadyHaveAccount;
  String get dontHaveAccount;
  String get loginTitle;
  String get loginSubtitle;
  String get registerTitle;
  String get registerSubtitle;
  String get forgotPasswordTitle;
  String get forgotPasswordSubtitle;
  String get forgotPasswordButton;
  String get backToLogin;
  String get rememberPassword;
  String get termsAndPrivacy;
  String get continueWithGoogle;
  
  // Validation Messages
  String get emailRequired;
  String get emailInvalid;
  String get passwordRequired;
  String get passwordTooShort;
  String get passwordsDoNotMatch;
  String get fullNameRequired;
  String get phoneInvalid;
  
  // Hint texts
  String get enterEmail;
  String get enterPassword;
  String get enterFullName;
  String get enterPhoneNumber;
  String get confirmYourPassword;
  
  // Success Messages
  String get registrationSuccessful;
  String get loginSuccessful;
  String get passwordResetSent;
  
  // Error Messages
  String get loginFailed;
  String get registrationFailed;
  String get passwordResetFailed;
  String get networkError;
  String get unexpectedError;
  
  // Home
  String get homeTitle;
  String get searchRestaurants;
  String get nearbyRestaurants;
  String get popularRestaurants;
  String get topRated;
  String get fastDelivery;
  String get newRestaurants;
  String get viewAll;
  
  // Restaurant
  String get restaurantDetails;
  String get menu;
  String get reviews;
  String get info;
  String get openingHours;
  String get deliveryTime;
  String get deliveryFee;
  String get minimumOrder;
  String get rating;
  String get addToCart;
  String get outOfStock;
  
  // Cart
  String get cart;
  String get emptyCart;
  String get cartSubtotal;
  String get deliveryFees;
  String get total;
  String get checkout;
  String get removeFromCart;
  String get updateQuantity;
  String get viewCart;
  String get item;
  String get items;
  String viewCartWithItems(int count);
  
  // Orders
  String get orders;
  String get orderHistory;
  String get orderDetails;
  String get orderTracking;
  String get orderStatus;
  String get orderNumber;
  String get orderDate;
  String get orderTotal;
  String get reorder;
  String get trackOrder;
  String get orderReceived;
  String get orderPreparing;
  String get orderReady;
  String get orderDelivering;
  String get orderDelivered;
  String get orderCancelled;
  
  // Profile
  String get profile;
  String get myProfile;
  String get personalInfo;
  String get addresses;
  String get paymentMethods;
  String get orderHistoryProfile;
  String get settings;
  String get helpSupport;
  String get aboutUs;
  String get privacyPolicy;
  String get termsOfService;
  String get changePassword;
  String get notifications;
  String get language;
  String get theme;
  String get version;
  
  // Language Selection
  String get selectLanguage;
  String get choosePreferredLanguage;
  String get english;
  String get russian;
  String get uzbek;
  String get languageChanged;
  
  // Search Screen
  String get searchMenuItems;
  String get searchHint;
  String get noResultsFound;
  String get noResultsMessage;
  String get searchSuggestions;
  String get popularItems;
  String get recentSearches;
  String get clearAll;
  String get filterByCategory;
  String get allCategories;
  String get sortBy;
  String get sortByPopularity;
  String get sortByPrice;
  String get sortByRating;
  String get loadingMore;
  String get noMoreItems;
  String get ingredients;
  String get allergens;
  String get calories;
  String get preparationTime;
  String get minutes;
  String get from;
  String get searchResults;
  String get itemsFound;
  String get tryAgain;
  String get addedToCart;
  String get low;
  String get high;
  String get featured;
  String get unavailable;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
    case 'uz': return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue on GitHub with a '
    'reproducible sample app and the gen-l10n configuration that was used.'
  );
}