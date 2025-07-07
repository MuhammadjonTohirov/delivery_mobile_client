import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../../features/cart/presentation/pages/cart_page.dart';
import '../../../shared/utils/formatters/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';

class FloatingCartButton extends StatelessWidget {
  const FloatingCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoaded && state.itemCount > 0) {
          return Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CartPage(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          // Cart Icon with Badge
                          Stack(
                            children: [
                              const Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                                size: 24,
                              ),
                              if (state.itemCount > 0)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                    ),
                                    child: Text(
                                      '${state.itemCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          // Cart Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${state.itemCount} ${state.itemCount == 1 ? AppLocalizations.of(context).item : AppLocalizations.of(context).items}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context).viewCart,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Total Amount
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatCurrency(state.total, state.items),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Total',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          // Arrow Icon
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  String _formatCurrency(double amount, List<Map<String, dynamic>> items) {
    // Try to get currency info from the first item
    if (items.isNotEmpty) {
      final firstItem = items.first;
      final currencyCode = firstItem['currency_code'] as String?;
      final currencySymbol = firstItem['currency_symbol'] as String?;
      
      if (currencyCode != null || currencySymbol != null) {
        return CurrencyFormatter.formatWithCurrency(
          amount,
          currencyCode: currencyCode,
          currencySymbol: currencySymbol,
        );
      }
    }
    
    // Fallback to USD if no currency info available
    return CurrencyFormatter.formatUSD(amount);
  }
}