import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';

// Events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchInitialRequested extends SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged({required this.query});

  @override
  List<Object> get props => [query];
}

class SearchCategoryChanged extends SearchEvent {
  final String? category;

  const SearchCategoryChanged({this.category});

  @override
  List<Object?> get props => [category];
}

class SearchLoadMoreRequested extends SearchEvent {}

class SearchRefreshRequested extends SearchEvent {}

class SearchSortChanged extends SearchEvent {
  final String sortBy;

  const SearchSortChanged({required this.sortBy});

  @override
  List<Object> get props => [sortBy];
}

// States
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoadingWithData extends SearchState {
  final List<dynamic> menuItems;
  final List<dynamic> categories;
  final List<String> recentSearches;
  final String? currentQuery;
  final String? currentCategory;
  final String currentSort;
  final bool hasMore;
  final int currentPage;
  final int totalCount;

  const SearchLoadingWithData({
    required this.menuItems,
    required this.categories,
    required this.recentSearches,
    this.currentQuery,
    this.currentCategory,
    this.currentSort = 'popularity',
    this.hasMore = true,
    this.currentPage = 1,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [
    menuItems,
    categories,
    recentSearches,
    currentQuery,
    currentCategory,
    currentSort,
    hasMore,
    currentPage,
    totalCount,
  ];
}

class SearchLoaded extends SearchState {
  final List<dynamic> menuItems;
  final List<dynamic> categories;
  final List<String> recentSearches;
  final String? currentQuery;
  final String? currentCategory;
  final String currentSort;
  final bool hasMore;
  final int currentPage;
  final int totalCount;

  const SearchLoaded({
    required this.menuItems,
    required this.categories,
    required this.recentSearches,
    this.currentQuery,
    this.currentCategory,
    this.currentSort = 'popularity',
    this.hasMore = true,
    this.currentPage = 1,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [
    menuItems,
    categories,
    recentSearches,
    currentQuery,
    currentCategory,
    currentSort,
    hasMore,
    currentPage,
    totalCount,
  ];

  SearchLoaded copyWith({
    List<dynamic>? menuItems,
    List<dynamic>? categories,
    List<String>? recentSearches,
    String? currentQuery,
    String? currentCategory,
    String? currentSort,
    bool? hasMore,
    int? currentPage,
    int? totalCount,
  }) {
    return SearchLoaded(
      menuItems: menuItems ?? this.menuItems,
      categories: categories ?? this.categories,
      recentSearches: recentSearches ?? this.recentSearches,
      currentQuery: currentQuery ?? this.currentQuery,
      currentCategory: currentCategory ?? this.currentCategory,
      currentSort: currentSort ?? this.currentSort,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class SearchLoadingMore extends SearchState {
  final List<dynamic> menuItems;
  final List<dynamic> categories;
  final List<String> recentSearches;
  final String? currentQuery;
  final String? currentCategory;
  final String currentSort;
  final int currentPage;
  final int totalCount;

  const SearchLoadingMore({
    required this.menuItems,
    required this.categories,
    required this.recentSearches,
    this.currentQuery,
    this.currentCategory,
    this.currentSort = 'popularity',
    this.currentPage = 1,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [
    menuItems,
    categories,
    recentSearches,
    currentQuery,
    currentCategory,
    currentSort,
    currentPage,
    totalCount,
  ];
}

class SearchError extends SearchState {
  final String message;

  const SearchError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ApiService apiService;

  SearchBloc({required this.apiService}) : super(SearchInitial()) {
    on<SearchInitialRequested>(_onSearchInitialRequested);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchCategoryChanged>(_onSearchCategoryChanged);
    on<SearchLoadMoreRequested>(_onSearchLoadMoreRequested);
    on<SearchRefreshRequested>(_onSearchRefreshRequested);
    on<SearchSortChanged>(_onSearchSortChanged);
  }

  Future<void> _onSearchInitialRequested(
    SearchInitialRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    await _loadInitialData(emit);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (state is SearchLoaded) {
      final currentState = state as SearchLoaded;
      
      // Show loading overlay while keeping current UI
      emit(SearchLoadingWithData(
        menuItems: currentState.menuItems,
        categories: currentState.categories,
        recentSearches: currentState.recentSearches,
        currentQuery: currentState.currentQuery,
        currentCategory: currentState.currentCategory,
        currentSort: currentState.currentSort,
        hasMore: currentState.hasMore,
        currentPage: currentState.currentPage,
        totalCount: currentState.totalCount,
      ));
      
      // Add to recent searches if it's a meaningful search
      List<String> updatedRecentSearches = List.from(currentState.recentSearches);
      if (event.query.trim().isNotEmpty && event.query.trim().length > 2) {
        updatedRecentSearches.remove(event.query.trim());
        updatedRecentSearches.insert(0, event.query.trim());
        if (updatedRecentSearches.length > 10) {
          updatedRecentSearches = updatedRecentSearches.take(10).toList();
        }
      }
      
      await _searchMenuItems(
        emit,
        query: event.query.trim().isEmpty ? null : event.query.trim(),
        category: currentState.currentCategory,
        sortBy: currentState.currentSort,
        categories: currentState.categories,
        recentSearches: updatedRecentSearches,
        page: 1,
      );
    }
  }

  Future<void> _onSearchCategoryChanged(
    SearchCategoryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (state is SearchLoaded) {
      final currentState = state as SearchLoaded;
      
      // Keep current UI stable, only show loading overlay
      emit(SearchLoadingWithData(
        menuItems: currentState.menuItems,
        categories: currentState.categories,
        recentSearches: currentState.recentSearches,
        currentQuery: currentState.currentQuery,
        currentCategory: currentState.currentCategory,
        currentSort: currentState.currentSort,
        hasMore: currentState.hasMore,
        currentPage: currentState.currentPage,
        totalCount: currentState.totalCount,
      ));
      
      await _searchMenuItems(
        emit,
        query: currentState.currentQuery,
        category: event.category,
        sortBy: currentState.currentSort,
        categories: currentState.categories,
        recentSearches: currentState.recentSearches,
        page: 1,
      );
    }
  }

  Future<void> _onSearchLoadMoreRequested(
    SearchLoadMoreRequested event,
    Emitter<SearchState> emit,
  ) async {
    if (state is SearchLoaded) {
      final currentState = state as SearchLoaded;
      if (!currentState.hasMore) return;

      emit(SearchLoadingMore(
        menuItems: currentState.menuItems,
        categories: currentState.categories,
        recentSearches: currentState.recentSearches,
        currentQuery: currentState.currentQuery,
        currentCategory: currentState.currentCategory,
        currentSort: currentState.currentSort,
        currentPage: currentState.currentPage,
        totalCount: currentState.totalCount,
      ));

      await _searchMenuItems(
        emit,
        query: currentState.currentQuery,
        category: currentState.currentCategory,
        sortBy: currentState.currentSort,
        categories: currentState.categories,
        recentSearches: currentState.recentSearches,
        page: currentState.currentPage + 1,
        existingItems: currentState.menuItems,
      );
    }
  }

  Future<void> _onSearchRefreshRequested(
    SearchRefreshRequested event,
    Emitter<SearchState> emit,
  ) async {
    if (state is SearchLoaded) {
      final currentState = state as SearchLoaded;
      await _searchMenuItems(
        emit,
        query: currentState.currentQuery,
        category: currentState.currentCategory,
        sortBy: currentState.currentSort,
        categories: currentState.categories,
        recentSearches: currentState.recentSearches,
        page: 1,
      );
    } else {
      await _loadInitialData(emit);
    }
  }

  Future<void> _onSearchSortChanged(
    SearchSortChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (state is SearchLoaded) {
      final currentState = state as SearchLoaded;
      
      // Keep current UI stable, only show loading overlay
      emit(SearchLoadingWithData(
        menuItems: currentState.menuItems,
        categories: currentState.categories,
        recentSearches: currentState.recentSearches,
        currentQuery: currentState.currentQuery,
        currentCategory: currentState.currentCategory,
        currentSort: currentState.currentSort,
        hasMore: currentState.hasMore,
        currentPage: currentState.currentPage,
        totalCount: currentState.totalCount,
      ));
      
      await _searchMenuItems(
        emit,
        query: currentState.currentQuery,
        category: currentState.currentCategory,
        sortBy: event.sortBy,
        categories: currentState.categories,
        recentSearches: currentState.recentSearches,
        page: 1,
      );
    }
  }

  Future<void> _loadInitialData(Emitter<SearchState> emit) async {
    try {
      // Load categories and initial popular items
      final results = await Future.wait([
        apiService.getCategories(),
        apiService.searchMenuItems(page: 1, pageSize: 20),
      ]);

      final categoriesResponse = results[0];
      final menuItemsResponse = results[1];

      if (categoriesResponse.success && menuItemsResponse.success) {
        final menuData = menuItemsResponse.data as Map<String, dynamic>;
        final menuItems = menuData['results'] ?? menuData['data'] ?? [];
        final totalCount = menuData['count'] ?? 0;
        final hasMore = menuItems.length >= 20 && totalCount > 20;

        emit(SearchLoaded(
          menuItems: menuItems,
          categories: (categoriesResponse.data as List<dynamic>? ?? []),
          recentSearches: const [],
          hasMore: hasMore,
          currentPage: 1,
          totalCount: totalCount,
        ));
      } else {
        emit(SearchError(message: categoriesResponse.error ?? menuItemsResponse.error ?? 'Failed to load data'));
      }
    } catch (e) {
      emit(SearchError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _searchMenuItems(
    Emitter<SearchState> emit, {
    String? query,
    String? category,
    required String sortBy,
    required List<dynamic> categories,
    required List<String> recentSearches,
    required int page,
    List<dynamic>? existingItems,
  }) async {
    try {
      final response = await apiService.searchMenuItems(
        query: query,
        category: category,
        page: page,
        pageSize: 20,
      );

      if (response.success) {
        final data = response.data as Map<String, dynamic>;
        final newItems = data['results'] ?? data['data'] ?? [];
        final totalCount = data['count'] ?? 0;
        
        List<dynamic> allItems;
        if (existingItems != null && page > 1) {
          allItems = [...existingItems, ...newItems];
        } else {
          allItems = newItems;
        }

        final hasMore = newItems.length >= 20 && allItems.length < totalCount;

        emit(SearchLoaded(
          menuItems: allItems,
          categories: categories,
          recentSearches: recentSearches,
          currentQuery: query,
          currentCategory: category,
          currentSort: sortBy,
          hasMore: hasMore,
          currentPage: page,
          totalCount: totalCount,
        ));
      } else {
        emit(SearchError(message: response.error ?? 'Failed to search menu items'));
      }
    } catch (e) {
      emit(SearchError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }
}