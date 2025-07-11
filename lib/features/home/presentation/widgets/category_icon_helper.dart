import 'package:flutter/material.dart';

/// Category icon helper following Single Responsibility Principle
/// Responsible only for mapping category names to appropriate icons
class CategoryIconHelper {
  static IconData getCategoryIcon(String name) {
    final lowercaseName = name.toLowerCase();
    
    if (lowercaseName.contains('pizza')) return Icons.local_pizza;
    if (lowercaseName.contains('burger')) return Icons.lunch_dining;
    if (lowercaseName.contains('asian') || lowercaseName.contains('chinese')) {
      return Icons.ramen_dining;
    }
    if (lowercaseName.contains('dessert') || lowercaseName.contains('sweet')) {
      return Icons.cake;
    }
    if (lowercaseName.contains('coffee') || lowercaseName.contains('drink')) {
      return Icons.local_cafe;
    }
    if (lowercaseName.contains('salad') || lowercaseName.contains('healthy')) {
      return Icons.eco;
    }
    
    return Icons.restaurant;
  }
}