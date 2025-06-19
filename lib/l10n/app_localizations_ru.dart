import 'app_localizations.dart';

class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu() : super('ru');

  @override
  String get appName => 'Доставка';
  
  // Common
  @override
  String get ok => 'ОК';
  @override
  String get cancel => 'Отмена';
  @override
  String get yes => 'Да';
  @override
  String get no => 'Нет';
  @override
  String get loading => 'Загрузка...';
  @override
  String get error => 'Ошибка';
  @override
  String get success => 'Успешно';
  @override
  String get retry => 'Повторить';
  @override
  String get save => 'Сохранить';
  @override
  String get edit => 'Редактировать';
  @override
  String get delete => 'Удалить';
  @override
  String get back => 'Назад';
  @override
  String get next => 'Далее';
  @override
  String get done => 'Готово';
  @override
  String get search => 'Поиск';
  @override
  String get filter => 'Фильтр';
  @override
  String get sort => 'Сортировка';
  @override
  String get clear => 'Очистить';
  @override
  String get apply => 'Применить';
  @override
  String get close => 'Закрыть';
  
  // Authentication
  @override
  String get signIn => 'Войти';
  @override
  String get signUp => 'Регистрация';
  @override
  String get signOut => 'Выйти';
  @override
  String get logout => 'Выход';
  @override
  String get email => 'Email';
  @override
  String get password => 'Пароль';
  @override
  String get confirmPassword => 'Подтвердить пароль';
  @override
  String get fullName => 'Полное имя';
  @override
  String get firstName => 'Имя';
  @override
  String get lastName => 'Фамилия';
  @override
  String get phoneNumber => 'Номер телефона';
  @override
  String get phoneOptional => 'Номер телефона (необязательно)';
  @override
  String get forgotPassword => 'Забыли пароль?';
  @override
  String get createAccount => 'Создать аккаунт';
  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт? ';
  @override
  String get dontHaveAccount => 'Нет аккаунта? ';
  @override
  String get loginTitle => 'Добро пожаловать';
  @override
  String get loginSubtitle => 'Войдите, чтобы продолжить';
  @override
  String get registerTitle => 'Создать аккаунт';
  @override
  String get registerSubtitle => 'Присоединяйтесь для быстрой доставки';
  @override
  String get forgotPasswordTitle => 'Забыли пароль?';
  @override
  String get forgotPasswordSubtitle => 'Не волнуйтесь! Введите email и мы отправим инструкции для восстановления пароля.';
  @override
  String get forgotPasswordButton => 'Отправить инструкции';
  @override
  String get backToLogin => 'Помните пароль? ';
  @override
  String get rememberPassword => 'Помните пароль? ';
  @override
  String get termsAndPrivacy => 'Создавая аккаунт, вы соглашаетесь с нашими Условиями использования и Политикой конфиденциальности';
  @override
  String get continueWithGoogle => 'Продолжить с Google';
  
  // Validation Messages
  @override
  String get emailRequired => 'Пожалуйста, введите email';
  @override
  String get emailInvalid => 'Пожалуйста, введите корректный email';
  @override
  String get passwordRequired => 'Пожалуйста, введите пароль';
  @override
  String get passwordTooShort => 'Пароль должен содержать минимум 6 символов';
  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';
  @override
  String get fullNameRequired => 'Пожалуйста, введите полное имя';
  @override
  String get phoneInvalid => 'Пожалуйста, введите корректный номер телефона';
  
  // Hint texts
  @override
  String get enterEmail => 'Введите ваш email';
  @override
  String get enterPassword => 'Введите ваш пароль';
  @override
  String get enterFullName => 'Введите ваше полное имя';
  @override
  String get enterPhoneNumber => 'Введите номер телефона';
  @override
  String get confirmYourPassword => 'Подтвердите пароль';
  
  // Success Messages
  @override
  String get registrationSuccessful => 'Регистрация успешна! Пожалуйста, войдите с вашими данными.';
  @override
  String get loginSuccessful => 'Вход выполнен успешно!';
  @override
  String get passwordResetSent => 'Если ваш email зарегистрирован, вы получите инструкции для восстановления пароля.';
  
  // Error Messages
  @override
  String get loginFailed => 'Ошибка входа';
  @override
  String get registrationFailed => 'Ошибка регистрации';
  @override
  String get passwordResetFailed => 'Не удалось отправить инструкции';
  @override
  String get networkError => 'Ошибка сети. Проверьте подключение к интернету.';
  @override
  String get unexpectedError => 'Произошла неожиданная ошибка';
  
  // Home
  @override
  String get homeTitle => 'Главная';
  @override
  String get searchRestaurants => 'Поиск ресторанов, кухни...';
  @override
  String get nearbyRestaurants => 'Рестораны рядом';
  @override
  String get popularRestaurants => 'Популярные рестораны';
  @override
  String get topRated => 'Лучшие';
  @override
  String get fastDelivery => 'Быстрая доставка';
  @override
  String get newRestaurants => 'Новые рестораны';
  @override
  String get viewAll => 'Показать все';
  
  // Restaurant
  @override
  String get restaurantDetails => 'О ресторане';
  @override
  String get menu => 'Меню';
  @override
  String get reviews => 'Отзывы';
  @override
  String get info => 'Информация';
  @override
  String get openingHours => 'Часы работы';
  @override
  String get deliveryTime => 'Время доставки';
  @override
  String get deliveryFee => 'Стоимость доставки';
  @override
  String get minimumOrder => 'Минимальный заказ';
  @override
  String get rating => 'Рейтинг';
  @override
  String get addToCart => 'В корзину';
  @override
  String get outOfStock => 'Нет в наличии';
  
  // Cart
  @override
  String get cart => 'Корзина';
  @override
  String get emptyCart => 'Ваша корзина пуста';
  @override
  String get cartSubtotal => 'Подытог';
  @override
  String get deliveryFees => 'Доставка';
  @override
  String get total => 'Итого';
  @override
  String get checkout => 'Оформить заказ';
  @override
  String get removeFromCart => 'Удалить из корзины';
  @override
  String get updateQuantity => 'Изменить количество';
  
  // Orders
  @override
  String get orders => 'Заказы';
  @override
  String get orderHistory => 'История заказов';
  @override
  String get orderDetails => 'Детали заказа';
  @override
  String get orderTracking => 'Отслеживание заказа';
  @override
  String get orderStatus => 'Статус заказа';
  @override
  String get orderNumber => 'Номер заказа';
  @override
  String get orderDate => 'Дата заказа';
  @override
  String get orderTotal => 'Сумма заказа';
  @override
  String get reorder => 'Заказать снова';
  @override
  String get trackOrder => 'Отследить заказ';
  @override
  String get orderReceived => 'Заказ получен';
  @override
  String get orderPreparing => 'Готовится';
  @override
  String get orderReady => 'Готов';
  @override
  String get orderDelivering => 'Доставляется';
  @override
  String get orderDelivered => 'Доставлен';
  @override
  String get orderCancelled => 'Отменен';
  
  // Profile
  @override
  String get profile => 'Профиль';
  @override
  String get myProfile => 'Мой профиль';
  @override
  String get personalInfo => 'Личная информация';
  @override
  String get addresses => 'Адреса';
  @override
  String get paymentMethods => 'Способы оплаты';
  @override
  String get orderHistoryProfile => 'История заказов';
  @override
  String get settings => 'Настройки';
  @override
  String get helpSupport => 'Помощь и поддержка';
  @override
  String get aboutUs => 'О нас';
  @override
  String get privacyPolicy => 'Политика конфиденциальности';
  @override
  String get termsOfService => 'Условия использования';
  @override
  String get changePassword => 'Сменить пароль';
  @override
  String get notifications => 'Уведомления';
  @override
  String get language => 'Язык';
  @override
  String get theme => 'Тема';
  @override
  String get version => 'Версия';
  
  // Language Selection
  @override
  String get selectLanguage => 'Выберите язык';
  @override
  String get choosePreferredLanguage => 'Выберите предпочитаемый язык';
  @override
  String get english => 'English';
  @override
  String get russian => 'Русский';
  @override
  String get uzbek => 'O\'zbek';
  @override
  String get languageChanged => 'Язык успешно изменен';
  
  // Search Screen
  @override
  String get searchMenuItems => 'Поиск блюд';
  @override
  String get searchHint => 'Поиск еды, ресторанов...';
  @override
  String get noResultsFound => 'Результаты не найдены';
  @override
  String get noResultsMessage => 'Мы не смогли найти элементы, соответствующие вашему запросу. Попробуйте изменить условия поиска.';
  @override
  String get searchSuggestions => 'Предложения поиска';
  @override
  String get popularItems => 'Популярные блюда';
  @override
  String get recentSearches => 'Недавние поиски';
  @override
  String get clearAll => 'Очистить все';
  @override
  String get filterByCategory => 'Фильтр по категории';
  @override
  String get allCategories => 'Все категории';
  @override
  String get sortBy => 'Сортировать по';
  @override
  String get sortByPopularity => 'Популярности';
  @override
  String get sortByPrice => 'Цене';
  @override
  String get sortByRating => 'Рейтингу';
  @override
  String get loadingMore => 'Загрузка...';
  @override
  String get noMoreItems => 'Больше нет элементов';
  
  @override
  String get ingredients => 'Ингредиенты';
  @override
  String get allergens => 'Аллергены';
  @override
  String get calories => 'Калории';
  @override
  String get preparationTime => 'Время приготовления';
  @override
  String get minutes => 'мин';
  @override
  String get from => 'от';
  @override
  String get searchResults => 'Результаты поиска';
  @override
  String get itemsFound => 'найдено элементов';
  @override
  String get tryAgain => 'Попробовать снова';
  @override
  String get addedToCart => 'добавлено в корзину';
  @override
  String get low => 'Низкая';
  @override
  String get high => 'Высокая';
  @override
  String get featured => 'Рекомендуемое';
  @override
  String get unavailable => 'Недоступно';
}