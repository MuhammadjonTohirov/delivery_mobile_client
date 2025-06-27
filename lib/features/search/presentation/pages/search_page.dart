import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/search_bloc.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_chips_widget.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/search_suggestions_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    context.read<SearchBloc>().add(SearchInitialRequested());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<SearchBloc>().add(SearchLoadMoreRequested());
    }
  }

  void _onSearchChanged(String query) {
    // Cancel the previous timer
    _debounceTimer?.cancel();
    
    // Start a new timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      context.read<SearchBloc>().add(SearchQueryChanged(query: query));
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is SearchLoaded || state is SearchLoadingMore || state is SearchLoadingWithData) {
            // Extract common properties from all state types
            final categories = state is SearchLoaded 
                ? state.categories 
                : state is SearchLoadingMore 
                  ? state.categories 
                  : state is SearchLoadingWithData
                    ? state.categories
                    : <dynamic>[];
            final currentCategory = state is SearchLoaded 
                ? state.currentCategory 
                : state is SearchLoadingMore 
                  ? state.currentCategory 
                  : state is SearchLoadingWithData
                    ? state.currentCategory
                    : null;
            final currentSort = state is SearchLoaded 
                ? state.currentSort 
                : state is SearchLoadingMore 
                  ? state.currentSort 
                  : state is SearchLoadingWithData
                    ? state.currentSort
                    : 'popularity';
            final menuItems = state is SearchLoaded 
                ? state.menuItems 
                : state is SearchLoadingMore 
                  ? state.menuItems 
                  : state is SearchLoadingWithData
                    ? state.menuItems
                    : <dynamic>[];
            final currentQuery = state is SearchLoaded 
                ? state.currentQuery 
                : state is SearchLoadingMore 
                  ? state.currentQuery 
                  : state is SearchLoadingWithData
                    ? state.currentQuery
                    : null;
            final totalCount = state is SearchLoaded 
                ? state.totalCount 
                : state is SearchLoadingMore 
                  ? state.totalCount 
                  : state is SearchLoadingWithData
                    ? state.totalCount
                    : 0;
            final recentSearches = state is SearchLoaded 
                ? state.recentSearches 
                : state is SearchLoadingMore 
                  ? state.recentSearches 
                  : state is SearchLoadingWithData
                    ? state.recentSearches
                    : <String>[];
            
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SearchBloc>().add(SearchRefreshRequested());
              },
              child: Column(
                children: [
                  // Header with green background and centered title
                  Container(
                    padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Centered title
                        Text(
                          l10n.search,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        SearchBarWidget(
                          controller: _searchController,
                          onSearchChanged: _onSearchChanged,
                        ),
                      ],
                    ),
                  ),
                  
                  // Filter Chips
                  FilterChipsWidget(
                    categories: categories,
                    selectedCategory: currentCategory,
                    selectedSort: currentSort,
                    onCategorySelected: (category) {
                      context.read<SearchBloc>().add(SearchCategoryChanged(category: category));
                    },
                    onSortSelected: (sort) {
                      context.read<SearchBloc>().add(SearchSortChanged(sortBy: sort));
                    },
                  ),
                  
                  // Search Results Header
                  if (currentQuery != null || currentCategory != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            '$totalCount ${l10n.itemsFound}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (currentQuery != null || currentCategory != null)
                            TextButton(
                              onPressed: () {
                                _debounceTimer?.cancel();
                                _searchController.clear();
                                context.read<SearchBloc>().add(const SearchQueryChanged(query: ''));
                                context.read<SearchBloc>().add(const SearchCategoryChanged(category: null));
                              },
                              child: Text(l10n.clearAll),
                            ),
                        ],
                      ),
                    ),
                  
                  // Content with overlay loading
                  Expanded(
                    child: Stack(
                      children: [
                        // Main content
                        menuItems.isEmpty && currentQuery == null
                            ? SearchSuggestionsWidget(
                                categories: categories,
                                recentSearches: recentSearches,
                                onSearchTap: (query) {
                                  _debounceTimer?.cancel();
                                  _searchController.text = query;
                                  context.read<SearchBloc>().add(SearchQueryChanged(query: query));
                                },
                                onCategoryTap: (category) {
                                  context.read<SearchBloc>().add(SearchCategoryChanged(category: category));
                                },
                              )
                            : menuItems.isEmpty
                                ? _buildNoResults(l10n)
                                : _buildSearchResults(menuItems, state is SearchLoadingMore, state is SearchLoaded ? state.hasMore : false, l10n),
                        
                        // Overlay loading indicator only over content area
                        if (state is SearchLoadingWithData)
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          
          // For SearchError state, show error UI
          if (state is SearchError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SearchBloc>().add(SearchRefreshRequested());
                    },
                    child: Text(l10n.tryAgain),
                  ),
                ],
              ),
            );
          }
          
          // For SearchInitial state, show welcome screen
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.searchMenuItems,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.searchHint,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    ],
  ),
    );
  }

  Widget _buildNoResults(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noResultsFound,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noResultsMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _debounceTimer?.cancel();
                _searchController.clear();
                context.read<SearchBloc>().add(const SearchQueryChanged(query: ''));
                context.read<SearchBloc>().add(const SearchCategoryChanged(category: null));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(l10n.clearAll),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<dynamic> menuItems, bool isLoadingMore, bool hasMore, AppLocalizations l10n) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: menuItems.length + (isLoadingMore ? 1 : hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= menuItems.length) {
          if (isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
        
        final menuItem = menuItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MenuItemCard(
            menuItem: menuItem,
            onTap: () {
              // Handle menu item tap
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${menuItem['name']} ${l10n.addedToCart}')),
              );
            },
          ),
        );
      },
    );
  }
}