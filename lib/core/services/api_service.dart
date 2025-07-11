import 'package:image_picker/image_picker.dart';
import 'api/api_service_auth.dart';
import 'api/api_service_cart.dart';
import 'api/api_service_order.dart';
import 'api/api_service_promotion.dart';
import 'api/api_service_restaurant.dart';
import 'api/api_service_review.dart';
import 'api/api_service_search.dart';
import 'api/base_api_service.dart';

/// Comprehensive API service that combines all modular API services
/// This provides a single point of access to all API functionality
/// while maintaining clean separation of concerns internally
class ApiService {
  // Service modules
  late final AuthApiService _authService;
  late final RestaurantApiService _restaurantService;
  late final CartApiService _cartService;
  late final OrderApiService _orderService;
  late final SearchApiService _searchService;
  late final PromotionApiService _promotionService;
  late final ReviewApiService _reviewService;

  ApiService() {
    _authService = AuthApiService();
    _restaurantService = RestaurantApiService();
    _cartService = CartApiService();
    _orderService = OrderApiService();
    _searchService = SearchApiService();
    _promotionService = PromotionApiService();
    _reviewService = ReviewApiService();
  }

  // Auth methods
  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) =>
      _authService.login(email, password);

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) => _authService.register(
    email: email,
    password: password,
    fullName: fullName,
    phone: phone,
  );

  Future<ApiResponse<Map<String, dynamic>>> forgotPassword(String email) =>
      _authService.forgotPassword(email);

  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() =>
      _authService.getUserProfile();

  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    String? fullName,
    String? phone,
    String? email,
  }) => _authService.updateProfile(
    fullName: fullName,
    phone: phone,
    email: email,
  );

  Future<ApiResponse<Map<String, dynamic>>> updateProfileImage({
    required XFile imageFile,
  }) => _authService.updateProfileImage(imageFile: imageFile);

  // Restaurant methods
  Future<ApiResponse<List<dynamic>>> getRestaurants({
    double? latitude,
    double? longitude,
    String? search,
    String? category,
    int page = 1,
  }) => _restaurantService.getRestaurants(
    latitude: latitude,
    longitude: longitude,
    search: search,
    category: category,
    page: page,
  );

  Future<ApiResponse<List<dynamic>>> getFeaturedRestaurants({
    double? latitude,
    double? longitude,
  }) => _restaurantService.getFeaturedRestaurants(
    latitude: latitude,
    longitude: longitude,
  );

  Future<ApiResponse<List<dynamic>>> getCategories() =>
      _restaurantService.getCategories();

  Future<ApiResponse<Map<String, dynamic>>> getRestaurantDetails(String restaurantId) =>
      _restaurantService.getRestaurantDetails(restaurantId);

  Future<ApiResponse<List<dynamic>>> getRestaurantMenu(String restaurantId) =>
      _restaurantService.getRestaurantMenu(restaurantId);

  Future<ApiResponse<Map<String, dynamic>>> getMenuItems({
    String? restaurantId,
    String? query,
    String? category,
    int page = 1,
    int pageSize = 20,
  }) => _restaurantService.getMenuItems(
    restaurantId: restaurantId,
    query: query,
    category: category,
    page: page,
    pageSize: pageSize,
  );

  Future<ApiResponse<Map<String, dynamic>>> getMenuItemDetails(String itemId) =>
      _restaurantService.getMenuItemDetails(itemId);

  // Cart methods
  Future<ApiResponse<Map<String, dynamic>>> getCart() => _cartService.getCart();

  Future<ApiResponse<Map<String, dynamic>>> addToCart({
    required String menuItemId,
    required int quantity,
    String? notes,
    List<String>? selectedOptions,
  }) => _cartService.addToCart(
    menuItemId: menuItemId,
    quantity: quantity,
    notes: notes,
    selectedOptions: selectedOptions,
  );

  Future<ApiResponse<Map<String, dynamic>>> updateCartItem({
    required String cartItemId,
    required int quantity,
    String? notes,
    List<String>? selectedOptions,
  }) => _cartService.updateCartItem(
    cartItemId: cartItemId,
    quantity: quantity,
    notes: notes,
    selectedOptions: selectedOptions,
  );

  Future<ApiResponse<Map<String, dynamic>>> removeFromCart(String cartItemId) =>
      _cartService.removeFromCart(cartItemId);

  Future<ApiResponse<Map<String, dynamic>>> clearCart() => _cartService.clearCart();

  // Order methods
  Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required int restaurantId,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> deliveryAddress,
    String? notes,
    String? promoCode,
  }) => _orderService.createOrder(
    restaurantId: restaurantId,
    items: items,
    deliveryAddress: deliveryAddress,
    notes: notes,
    promoCode: promoCode,
  );

  Future<ApiResponse<List<dynamic>>> getOrders({int page = 1}) =>
      _orderService.getOrders(page: page);

  Future<ApiResponse<Map<String, dynamic>>> getOrderDetails(dynamic orderId) =>
      _orderService.getOrderDetails(orderId);

  Future<ApiResponse<Map<String, dynamic>>> trackOrder(String orderId) =>
      _orderService.trackOrder(orderId);

  // Search methods
  Future<ApiResponse<Map<String, dynamic>>> search(String query, {
    double? latitude,
    double? longitude,
  }) => _searchService.search(
    query,
    latitude: latitude,
    longitude: longitude,
  );

  Future<ApiResponse<Map<String, dynamic>>> searchMenuItems({
    String? query,
    String? category,
    int page = 1,
    int pageSize = 20,
  }) => _searchService.searchMenuItems(
    query: query,
    category: category,
    page: page,
    pageSize: pageSize,
  );

  // Promotion methods
  Future<ApiResponse<List<dynamic>>> getPromotions() =>
      _promotionService.getPromotions();

  Future<ApiResponse<Map<String, dynamic>>> validatePromoCode(String code) =>
      _promotionService.validatePromoCode(code);

  // Review methods
  Future<ApiResponse<List<dynamic>>> getRestaurantReviews(
    String restaurantId, {
    int page = 1,
    int pageSize = 20,
  }) => _reviewService.getRestaurantReviews(
    restaurantId,
    page: page,
    pageSize: pageSize,
  );

  Future<ApiResponse<Map<String, dynamic>>> submitReview({
    required int restaurantId,
    required int orderId,
    required int rating,
    String? comment,
  }) => _reviewService.submitReview(
    restaurantId: restaurantId,
    orderId: orderId,
    rating: rating,
    comment: comment,
  );
}