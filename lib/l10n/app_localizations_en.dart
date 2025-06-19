import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn() : super('en');

  @override
  String get appName => 'Delivery Customer';
  
  // Common
  @override
  String get ok => 'OK';
  @override
  String get cancel => 'Cancel';
  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';
  @override
  String get loading => 'Loading...';
  @override
  String get error => 'Error';
  @override
  String get success => 'Success';
  @override
  String get retry => 'Retry';
  @override
  String get save => 'Save';
  @override
  String get edit => 'Edit';
  @override
  String get delete => 'Delete';
  @override
  String get back => 'Back';
  @override
  String get next => 'Next';
  @override
  String get done => 'Done';
  @override
  String get search => 'Search';
  @override
  String get filter => 'Filter';
  @override
  String get sort => 'Sort';
  @override
  String get clear => 'Clear';
  @override
  String get apply => 'Apply';
  @override
  String get close => 'Close';
  
  // Authentication
  @override
  String get signIn => 'Sign In';
  @override
  String get signUp => 'Sign Up';
  @override
  String get signOut => 'Sign Out';
  @override
  String get logout => 'Logout';
  @override
  String get email => 'Email';
  @override
  String get password => 'Password';
  @override
  String get confirmPassword => 'Confirm Password';
  @override
  String get fullName => 'Full Name';
  @override
  String get firstName => 'First Name';
  @override
  String get lastName => 'Last Name';
  @override
  String get phoneNumber => 'Phone Number';
  @override
  String get phoneOptional => 'Phone Number (Optional)';
  @override
  String get forgotPassword => 'Forgot Password?';
  @override
  String get createAccount => 'Create Account';
  @override
  String get alreadyHaveAccount => 'Already have an account? ';
  @override
  String get dontHaveAccount => "Don't have an account? ";
  @override
  String get loginTitle => 'Welcome Back';
  @override
  String get loginSubtitle => 'Sign in to continue';
  @override
  String get registerTitle => 'Create Account';
  @override
  String get registerSubtitle => 'Join us for fast delivery';
  @override
  String get forgotPasswordTitle => 'Forgot Password?';
  @override
  String get forgotPasswordSubtitle => "Don't worry! Enter your email and we'll send you password reset instructions.";
  @override
  String get forgotPasswordButton => 'Send Reset Instructions';
  @override
  String get backToLogin => 'Remember your password? ';
  @override
  String get rememberPassword => 'Remember your password? ';
  @override
  String get termsAndPrivacy => 'By creating an account, you agree to our Terms of Service and Privacy Policy';
  @override
  String get continueWithGoogle => 'Continue with Google';
  
  // Validation Messages
  @override
  String get emailRequired => 'Please enter your email';
  @override
  String get emailInvalid => 'Please enter a valid email';
  @override
  String get passwordRequired => 'Please enter your password';
  @override
  String get passwordTooShort => 'Password must be at least 6 characters';
  @override
  String get passwordsDoNotMatch => 'Passwords do not match';
  @override
  String get fullNameRequired => 'Please enter your full name';
  @override
  String get phoneInvalid => 'Please enter a valid phone number';
  
  // Hint texts
  @override
  String get enterEmail => 'Enter your email';
  @override
  String get enterPassword => 'Enter your password';
  @override
  String get enterFullName => 'Enter your full name';
  @override
  String get enterPhoneNumber => 'Enter your phone number';
  @override
  String get confirmYourPassword => 'Confirm your password';
  
  // Success Messages
  @override
  String get registrationSuccessful => 'Registration successful! Please login with your credentials.';
  @override
  String get loginSuccessful => 'Login successful!';
  @override
  String get passwordResetSent => 'If your email is registered, you will receive password reset instructions.';
  
  // Error Messages
  @override
  String get loginFailed => 'Login failed';
  @override
  String get registrationFailed => 'Registration failed';
  @override
  String get passwordResetFailed => 'Failed to send reset instructions';
  @override
  String get networkError => 'Network error. Please check your connection.';
  @override
  String get unexpectedError => 'An unexpected error occurred';
  
  // Home
  @override
  String get homeTitle => 'Home';
  @override
  String get searchRestaurants => 'Search restaurants, cuisines...';
  @override
  String get nearbyRestaurants => 'Nearby Restaurants';
  @override
  String get popularRestaurants => 'Popular Restaurants';
  @override
  String get topRated => 'Top Rated';
  @override
  String get fastDelivery => 'Fast Delivery';
  @override
  String get newRestaurants => 'New Restaurants';
  @override
  String get viewAll => 'View All';
  
  // Restaurant
  @override
  String get restaurantDetails => 'Restaurant Details';
  @override
  String get menu => 'Menu';
  @override
  String get reviews => 'Reviews';
  @override
  String get info => 'Info';
  @override
  String get openingHours => 'Opening Hours';
  @override
  String get deliveryTime => 'Delivery Time';
  @override
  String get deliveryFee => 'Delivery Fee';
  @override
  String get minimumOrder => 'Minimum Order';
  @override
  String get rating => 'Rating';
  @override
  String get addToCart => 'Add to Cart';
  @override
  String get outOfStock => 'Out of Stock';
  
  // Cart
  @override
  String get cart => 'Cart';
  @override
  String get emptyCart => 'Your cart is empty';
  @override
  String get cartSubtotal => 'Subtotal';
  @override
  String get deliveryFees => 'Delivery Fees';
  @override
  String get total => 'Total';
  @override
  String get checkout => 'Checkout';
  @override
  String get removeFromCart => 'Remove from Cart';
  @override
  String get updateQuantity => 'Update Quantity';
  
  // Orders
  @override
  String get orders => 'Orders';
  @override
  String get orderHistory => 'Order History';
  @override
  String get orderDetails => 'Order Details';
  @override
  String get orderTracking => 'Order Tracking';
  @override
  String get orderStatus => 'Order Status';
  @override
  String get orderNumber => 'Order Number';
  @override
  String get orderDate => 'Order Date';
  @override
  String get orderTotal => 'Order Total';
  @override
  String get reorder => 'Reorder';
  @override
  String get trackOrder => 'Track Order';
  @override
  String get orderReceived => 'Order Received';
  @override
  String get orderPreparing => 'Preparing';
  @override
  String get orderReady => 'Ready';
  @override
  String get orderDelivering => 'Delivering';
  @override
  String get orderDelivered => 'Delivered';
  @override
  String get orderCancelled => 'Cancelled';
  
  // Profile
  @override
  String get profile => 'Profile';
  @override
  String get myProfile => 'My Profile';
  @override
  String get personalInfo => 'Personal Information';
  @override
  String get addresses => 'Addresses';
  @override
  String get paymentMethods => 'Payment Methods';
  @override
  String get orderHistoryProfile => 'Order History';
  @override
  String get settings => 'Settings';
  @override
  String get helpSupport => 'Help & Support';
  @override
  String get aboutUs => 'About Us';
  @override
  String get privacyPolicy => 'Privacy Policy';
  @override
  String get termsOfService => 'Terms of Service';
  @override
  String get changePassword => 'Change Password';
  @override
  String get notifications => 'Notifications';
  @override
  String get language => 'Language';
  @override
  String get theme => 'Theme';
  @override
  String get version => 'Version';
  
  // Language Selection
  @override
  String get selectLanguage => 'Select Language';
  @override
  String get choosePreferredLanguage => 'Choose your preferred language';
  @override
  String get english => 'English';
  @override
  String get russian => 'Русский';
  @override
  String get uzbek => 'O\'zbek';
  @override
  String get languageChanged => 'Language changed successfully';
  
  // Search Screen
  @override
  String get searchMenuItems => 'Search Menu Items';
  @override
  String get searchHint => 'Search for food, restaurants...';
  @override
  String get noResultsFound => 'No Results Found';
  @override
  String get noResultsMessage => 'We couldn\'t find any items matching your search. Try adjusting your search terms.';
  @override
  String get searchSuggestions => 'Search Suggestions';
  @override
  String get popularItems => 'Popular Items';
  @override
  String get recentSearches => 'Recent Searches';
  @override
  String get clearAll => 'Clear All';
  @override
  String get filterByCategory => 'Filter by Category';
  @override
  String get allCategories => 'All Categories';
  @override
  String get sortBy => 'Sort By';
  @override
  String get sortByPopularity => 'Popularity';
  @override
  String get sortByPrice => 'Price';
  @override
  String get sortByRating => 'Rating';
  @override
  String get loadingMore => 'Loading more...';
  @override
  String get noMoreItems => 'No more items';
  @override
  String get ingredients => 'Ingredients';
  @override
  String get allergens => 'Allergens';
  @override
  String get calories => 'Calories';
  @override
  String get preparationTime => 'Preparation Time';
  @override
  String get minutes => 'min';
  @override
  String get from => 'from';
  @override
  String get searchResults => 'Search Results';
  @override
  String get itemsFound => 'items found';
  @override
  String get tryAgain => 'Try Again';
  @override
  String get addedToCart => 'added to cart';
  @override
  String get low => 'Low';
  @override
  String get high => 'High';
  @override
  String get featured => 'Featured';
  @override
  String get unavailable => 'Unavailable';
}