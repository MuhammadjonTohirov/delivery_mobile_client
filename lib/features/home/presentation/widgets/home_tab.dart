import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/models.dart';
import '../bloc/home_bloc.dart';
import 'welcome_section.dart';
import 'search_bar_widget.dart';
import 'categories_section.dart';
import 'featured_restaurants_section.dart';
import 'restaurants_section.dart';

/// Home tab component following Single Responsibility Principle
/// Responsible only for managing the home screen layout and state
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Customer'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return switch (state) {
            HomeLoading() => const Center(child: CircularProgressIndicator()),
            HomeError(:final message) => _buildErrorView(context, message),
            HomeLoaded() => _buildLoadedView(context, state),
            _ => const Center(child: Text('Welcome! Pull down to refresh.')),
          };
        },
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: $message',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<HomeBloc>().add(HomeRefreshRequested());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedView(BuildContext context, HomeLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(HomeRefreshRequested());
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WelcomeSection(),
            const SizedBox(height: 24),
            const SearchBarWidget(),
            const SizedBox(height: 24),
            CategoriesSection(categories: state.categories),
            const SizedBox(height: 24),
            FeaturedRestaurantsSection(restaurants: state.featuredRestaurants),
            const SizedBox(height: 24),
            RestaurantsSection(restaurants: state.restaurants),
          ],
        ),
      ),
    );
  }
}