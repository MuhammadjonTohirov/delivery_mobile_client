# API Service Refactoring Guide

## Overview
The massive `api_service.dart` file has been refactored into smaller, logical, domain-specific service modules to improve maintainability, reduce confusion, and enable easier development.

## New Structure

### 1. Base API Service (`base_api_service.dart`)
- **Purpose**: Contains common HTTP client setup, interceptors, and shared utilities
- **Features**:
  - Dio HTTP client configuration
  - Authentication token injection
  - Request/response logging
  - Common error handling
  - Helper methods for list/paginated responses

### 2. Auth API Service (`api_service_auth.dart`)
- **Purpose**: Authentication and user profile management
- **Methods**:
  - `login()` - User login
  - `register()` - User registration
  - `forgotPassword()` - Password reset
  - `getUserProfile()` - Get user profile
  - `updateProfile()` - Update user profile
  - `updateProfileImage()` - Upload profile image

### 3. Restaurant API Service (`api_service_restaurant.dart`)
- **Purpose**: Restaurant and menu item management
- **Methods**:
  - `getRestaurants()` - List restaurants with filtering
  - `getFeaturedRestaurants()` - Get featured restaurants
  - `getCategories()` - Get restaurant categories
  - `getRestaurantDetails()` - Get specific restaurant details
  - `getRestaurantMenu()` - Get restaurant menu items
  - `getMenuItems()` - Search/filter menu items
  - `getMenuItemDetails()` - Get specific menu item details

### 4. Cart API Service (`api_service_cart.dart`)
- **Purpose**: Shopping cart operations
- **Methods**:
  - `getCart()` - Get current cart
  - `addToCart()` - Add item to cart
  - `updateCartItem()` - Update cart item quantity/options
  - `removeFromCart()` - Remove item from cart
  - `clearCart()` - Clear entire cart

### 5. Order API Service (`api_service_order.dart`)
- **Purpose**: Order management and tracking
- **Methods**:
  - `createOrder()` - Create new order
  - `getOrders()` - Get user order history
  - `getOrderDetails()` - Get specific order details
  - `trackOrder()` - Track order status

### 6. Search API Service (`api_service_search.dart`)
- **Purpose**: Search functionality
- **Methods**:
  - `search()` - General search across restaurants/items
  - `searchMenuItems()` - Specific menu item search

### 7. Promotion API Service (`api_service_promotion.dart`)
- **Purpose**: Promotions and promo codes
- **Methods**:
  - `getPromotions()` - Get active promotions
  - `validatePromoCode()` - Validate promo code

### 8. Review API Service (`api_service_review.dart`)
- **Purpose**: Reviews and ratings
- **Methods**:
  - `getRestaurantReviews()` - Get restaurant reviews
  - `submitReview()` - Submit new review

## Main API Service (`api_service.dart`)
The main `ApiService` class now acts as a facade that combines all modular services, maintaining the same public interface for backward compatibility.

## Benefits of Refactoring

### 1. **Improved Maintainability**
- Easier to locate specific functionality
- Smaller files are easier to understand and modify
- Clear separation of concerns

### 2. **Better Development Experience**
- Faster navigation and searching
- Reduced cognitive load when working on specific features
- Better code organization

### 3. **Enhanced Testability**
- Each service module can be tested independently
- Easier to mock specific service dependencies
- More focused unit tests

### 4. **Scalability**
- Easy to add new functionality to specific domains
- Clear boundaries for new features
- Reduced merge conflicts

### 5. **Code Reusability**
- Individual services can be used independently if needed
- Common functionality consolidated in base service
- Consistent patterns across all services

## Usage Examples

### Using Individual Services (if needed)
```dart
// For specialized use cases, you can use individual services
final authService = AuthApiService();
final cartService = CartApiService();

// Login
final loginResult = await authService.login(email, password);

// Add to cart
final cartResult = await cartService.addToCart(
  menuItemId: itemId,
  quantity: 2,
);
```

### Using Main API Service (recommended)
```dart
// Standard usage remains the same
final apiService = ApiService();

// Login
final loginResult = await apiService.login(email, password);

// Add to cart
final cartResult = await apiService.addToCart(
  menuItemId: itemId,
  quantity: 2,
);
```

## Migration Impact

### ✅ **Zero Breaking Changes**
- All existing code continues to work unchanged
- Same public API interface maintained
- No changes required in BLoCs or other services

### ✅ **Backward Compatibility**
- Original method signatures preserved
- Same return types and parameters
- Existing error handling unchanged

### ✅ **Performance**
- No performance impact
- Same underlying HTTP client
- Minimal overhead from delegation pattern

## File Organization

```
lib/core/services/
├── api_service.dart              # Main facade service
├── base_api_service.dart         # Common HTTP client & utilities
├── api_service_auth.dart         # Authentication services
├── api_service_cart.dart         # Cart operations
├── api_service_order.dart        # Order management
├── api_service_promotion.dart    # Promotions & promo codes
├── api_service_restaurant.dart   # Restaurant & menu services
├── api_service_review.dart       # Reviews & ratings
├── api_service_search.dart       # Search functionality
├── api_services.dart            # Export file for easy imports
├── api_service_original.dart    # Backup of original file
└── API_REFACTORING_GUIDE.md     # This documentation
```

## Future Improvements

1. **Add Request Caching**: Implement caching at the service level
2. **Add Request Retries**: Implement automatic retry logic for failed requests
3. **Add Request Queuing**: Queue requests during offline scenarios
4. **Add Analytics**: Track API usage and performance metrics
5. **Add Rate Limiting**: Implement client-side rate limiting

## Best Practices

1. **Single Responsibility**: Each service handles one domain
2. **Consistent Error Handling**: All services use the same error handling pattern
3. **Type Safety**: Strong typing throughout all services
4. **Documentation**: Clear documentation for all methods
5. **Testing**: Each service should have comprehensive unit tests

This refactoring maintains all existing functionality while providing a much cleaner, more maintainable codebase structure.