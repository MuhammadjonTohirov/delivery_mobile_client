import 'app_localizations.dart';

class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz() : super('uz');

  @override
  String get appName => 'Yetkazib berish';
  
  // Common
  @override
  String get ok => 'OK';
  @override
  String get cancel => 'Bekor qilish';
  @override
  String get yes => 'Ha';
  @override
  String get no => 'Yo\'q';
  @override
  String get loading => 'Yuklanmoqda...';
  @override
  String get error => 'Xatolik';
  @override
  String get success => 'Muvaffaqiyatli';
  @override
  String get retry => 'Qayta urinish';
  @override
  String get save => 'Saqlash';
  @override
  String get edit => 'Tahrirlash';
  @override
  String get delete => 'O\'chirish';
  @override
  String get back => 'Orqaga';
  @override
  String get next => 'Keyingi';
  @override
  String get done => 'Tayyor';
  @override
  String get search => 'Qidirish';
  @override
  String get filter => 'Filtr';
  @override
  String get sort => 'Saralash';
  @override
  String get clear => 'Tozalash';
  @override
  String get apply => 'Qo\'llash';
  @override
  String get close => 'Yopish';
  
  // Authentication
  @override
  String get signIn => 'Kirish';
  @override
  String get signUp => 'Ro\'yxatdan o\'tish';
  @override
  String get signOut => 'Chiqish';
  @override
  String get logout => 'Chiqish';
  @override
  String get email => 'Email';
  @override
  String get password => 'Parol';
  @override
  String get confirmPassword => 'Parolni tasdiqlang';
  @override
  String get fullName => 'To\'liq ism';
  @override
  String get firstName => 'Ism';
  @override
  String get lastName => 'Familiya';
  @override
  String get phoneNumber => 'Telefon raqami';
  @override
  String get phoneOptional => 'Telefon raqami (ixtiyoriy)';
  @override
  String get forgotPassword => 'Parolni unutdingizmi?';
  @override
  String get createAccount => 'Hisob yaratish';
  @override
  String get alreadyHaveAccount => 'Hisobingiz bormi? ';
  @override
  String get dontHaveAccount => 'Hisobingiz yo\'qmi? ';
  @override
  String get loginTitle => 'Xush kelibsiz';
  @override
  String get loginSubtitle => 'Davom etish uchun kiring';
  @override
  String get registerTitle => 'Hisob yaratish';
  @override
  String get registerSubtitle => 'Tez yetkazib berish uchun qo\'shiling';
  @override
  String get forgotPasswordTitle => 'Parolni unutdingizmi?';
  @override
  String get forgotPasswordSubtitle => 'Xavotir olmang! Emailingizni kiriting va biz sizga parolni tiklash yo\'riqnomasini jo\'natamiz.';
  @override
  String get forgotPasswordButton => 'Tiklash yo\'riqnomasini jo\'natish';
  @override
  String get backToLogin => 'Parolni eslaysizmi? ';
  @override
  String get rememberPassword => 'Parolni eslaysizmi? ';
  @override
  String get termsAndPrivacy => 'Hisob yaratish orqali siz bizning Foydalanish shartlari va Maxfiylik siyosatimizga rozilik bildirasiz';
  @override
  String get continueWithGoogle => 'Google bilan davom etish';
  
  // Validation Messages
  @override
  String get emailRequired => 'Iltimos, emailingizni kiriting';
  @override
  String get emailInvalid => 'Iltimos, to\'g\'ri email kiriting';
  @override
  String get passwordRequired => 'Iltimos, parolingizni kiriting';
  @override
  String get passwordTooShort => 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak';
  @override
  String get passwordsDoNotMatch => 'Parollar mos kelmaydi';
  @override
  String get fullNameRequired => 'Iltimos, to\'liq ismingizni kiriting';
  @override
  String get phoneInvalid => 'Iltimos, to\'g\'ri telefon raqami kiriting';
  
  // Hint texts
  @override
  String get enterEmail => 'Emailingizni kiriting';
  @override
  String get enterPassword => 'Parolingizni kiriting';
  @override
  String get enterFullName => 'To\'liq ismingizni kiriting';
  @override
  String get enterPhoneNumber => 'Telefon raqamingizni kiriting';
  @override
  String get confirmYourPassword => 'Parolingizni tasdiqlang';
  
  // Success Messages
  @override
  String get registrationSuccessful => 'Ro\'yxatdan o\'tish muvaffaqiyatli! Iltimos, hisobingizga kiring.';
  @override
  String get loginSuccessful => 'Muvaffaqiyatli kirildi!';
  @override
  String get passwordResetSent => 'Agar emailingiz ro\'yxatdan o\'tgan bo\'lsa, parolni tiklash yo\'riqnomasini olasiz.';
  
  // Error Messages
  @override
  String get loginFailed => 'Kirishda xatolik';
  @override
  String get registrationFailed => 'Ro\'yxatdan o\'tishda xatolik';
  @override
  String get passwordResetFailed => 'Yo\'riqnomani jo\'natishda xatolik';
  @override
  String get networkError => 'Tarmoq xatoligi. Internet ulanishini tekshiring.';
  @override
  String get unexpectedError => 'Kutilmagan xatolik yuz berdi';
  
  // Home
  @override
  String get homeTitle => 'Bosh sahifa';
  @override
  String get searchRestaurants => 'Restoranlar, taomlarni qidiring...';
  @override
  String get nearbyRestaurants => 'Yaqin restoranlar';
  @override
  String get popularRestaurants => 'Mashhur restoranlar';
  @override
  String get topRated => 'Eng yaxshi';
  @override
  String get fastDelivery => 'Tez yetkazib berish';
  @override
  String get newRestaurants => 'Yangi restoranlar';
  @override
  String get viewAll => 'Barchasini ko\'rish';
  
  // Restaurant
  @override
  String get restaurantDetails => 'Restoran haqida';
  @override
  String get menu => 'Menyu';
  @override
  String get reviews => 'Sharhlar';
  @override
  String get info => 'Ma\'lumot';
  @override
  String get openingHours => 'Ish vaqti';
  @override
  String get deliveryTime => 'Yetkazib berish vaqti';
  @override
  String get deliveryFee => 'Yetkazib berish narxi';
  @override
  String get minimumOrder => 'Minimal buyurtma';
  @override
  String get rating => 'Reyting';
  @override
  String get addToCart => 'Savatga qo\'shish';
  @override
  String get outOfStock => 'Tugagan';
  
  // Cart
  @override
  String get cart => 'Savat';
  @override
  String get emptyCart => 'Savatingiz bo\'sh';
  @override
  String get cartSubtotal => 'Jami';
  @override
  String get deliveryFees => 'Yetkazib berish';
  @override
  String get total => 'Umumiy';
  @override
  String get checkout => 'Buyurtma berish';
  @override
  String get removeFromCart => 'Savatdan olib tashlash';
  @override
  String get updateQuantity => 'Miqdorni o\'zgartirish';
  
  // Orders
  @override
  String get orders => 'Buyurtmalar';
  @override
  String get orderHistory => 'Buyurtmalar tarixi';
  @override
  String get orderDetails => 'Buyurtma tafsilotlari';
  @override
  String get orderTracking => 'Buyurtmani kuzatish';
  @override
  String get orderStatus => 'Buyurtma holati';
  @override
  String get orderNumber => 'Buyurtma raqami';
  @override
  String get orderDate => 'Buyurtma sanasi';
  @override
  String get orderTotal => 'Buyurtma summasi';
  @override
  String get reorder => 'Qayta buyurtma';
  @override
  String get trackOrder => 'Buyurtmani kuzatish';
  @override
  String get orderReceived => 'Buyurtma qabul qilindi';
  @override
  String get orderPreparing => 'Tayyorlanmoqda';
  @override
  String get orderReady => 'Tayyor';
  @override
  String get orderDelivering => 'Yetkazilmoqda';
  @override
  String get orderDelivered => 'Yetkazildi';
  @override
  String get orderCancelled => 'Bekor qilindi';
  
  // Profile
  @override
  String get profile => 'Profil';
  @override
  String get myProfile => 'Mening profilim';
  @override
  String get personalInfo => 'Shaxsiy ma\'lumotlar';
  @override
  String get addresses => 'Manzillar';
  @override
  String get paymentMethods => 'To\'lov usullari';
  @override
  String get orderHistoryProfile => 'Buyurtmalar tarixi';
  @override
  String get settings => 'Sozlamalar';
  @override
  String get helpSupport => 'Yordam va qo\'llab-quvvatlash';
  @override
  String get aboutUs => 'Biz haqimizda';
  @override
  String get privacyPolicy => 'Maxfiylik siyosati';
  @override
  String get termsOfService => 'Foydalanish shartlari';
  @override
  String get changePassword => 'Parolni o\'zgartirish';
  @override
  String get notifications => 'Bildirishnomalar';
  @override
  String get language => 'Til';
  @override
  String get theme => 'Mavzu';
  @override
  String get version => 'Versiya';
  
  // Language Selection
  @override
  String get selectLanguage => 'Tilni tanlang';
  @override
  String get choosePreferredLanguage => 'Kerakli tilni tanlang';
  @override
  String get english => 'English';
  @override
  String get russian => 'Русский';
  @override
  String get uzbek => 'O\'zbek';
  @override
  String get languageChanged => 'Til muvaffaqiyatli o\'zgartirildi';
  
  // Search Screen
  @override
  String get searchMenuItems => 'Taomlarni qidirish';
  @override
  String get searchHint => 'Taom, restoran qidiring...';
  @override
  String get noResultsFound => 'Natija topilmadi';
  @override
  String get noResultsMessage => 'Qidiruv so\'rovingizga mos keladigan mahsulotlar topilmadi. Qidiruv shartlarini o\'zgartirib ko\'ring.';
  @override
  String get searchSuggestions => 'Qidiruv takliflari';
  @override
  String get popularItems => 'Mashhur taomlar';
  @override
  String get recentSearches => 'So\'nggi qidiruvlar';
  @override
  String get clearAll => 'Hammasini tozalash';
  @override
  String get filterByCategory => 'Kategoriya bo\'yicha filtr';
  @override
  String get allCategories => 'Barcha kategoriyalar';
  @override
  String get sortBy => 'Saralash';
  @override
  String get sortByPopularity => 'Mashhurlik';
  @override
  String get sortByPrice => 'Narx';
  @override
  String get sortByRating => 'Reyting';
  @override
  String get loadingMore => 'Yuklanmoqda...';
  @override
  String get noMoreItems => 'Boshqa mahsulotlar yo\'q';
  @override
  String get ingredients => 'Tarkibi';
  @override
  String get allergens => 'Allergenlar';
  @override
  String get calories => 'Kaloriya';
  @override
  String get preparationTime => 'Tayyorlash vaqti';
  @override
  String get minutes => 'daq';
  @override
  String get from => 'dan';
  @override
  String get searchResults => 'Qidiruv natijalari';
  @override
  String get itemsFound => 'ta mahsulot topildi';
  @override
  String get tryAgain => 'Qaytadan urinish';
  @override
  String get addedToCart => 'savatga qo\'shildi';
  @override
  String get low => 'Past';
  @override
  String get high => 'Yuqori';
  @override
  String get featured => 'Tavsiya etilgan';
  @override
  String get unavailable => 'Mavjud emas';
}