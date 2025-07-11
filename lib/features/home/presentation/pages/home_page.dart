import 'package:flutter/material.dart';
import '../widgets/main_navigation.dart';

/// Main home page following Single Responsibility Principle
/// Responsible only for providing the entry point to the home screen navigation
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavigation();
  }
}