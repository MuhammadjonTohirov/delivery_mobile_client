class CurrencyInfo {
  final String code;
  final String symbol;

  CurrencyInfo({
    required this.code,
    required this.symbol,
  });

  factory CurrencyInfo.fromJson(Map<String, dynamic> json) {
    return CurrencyInfo(
      code: json['code']?.toString() ?? 'USD',
      symbol: json['symbol']?.toString() ?? '\$',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'symbol': symbol,
    };
  }

  String formatPrice(double price) {
    switch (code.toUpperCase()) {
      case 'UZS':
        // UZS formatting: no decimals, space separator, symbol after
        return '${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]} ',
        )} $symbol';
      default:
        // Standard formatting: 2 decimals, comma separator, symbol before
        return '$symbol${price.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}';
    }
  }

  @override
  String toString() => 'CurrencyInfo(code: $code, symbol: $symbol)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencyInfo && other.code == code && other.symbol == symbol;
  }

  @override
  int get hashCode => code.hashCode ^ symbol.hashCode;
}