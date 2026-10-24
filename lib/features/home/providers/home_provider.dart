import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/provider_model.dart';

class ProvidersListNotifier extends StateNotifier<AsyncValue<List<ProviderModel>>> {
  ProvidersListNotifier() : super(const AsyncValue.data([])) {
    _initializeMockProviders();
  }

  void _initializeMockProviders() {
    final providers = ProviderModel.mockProviders;
    state = AsyncValue.data(providers);
  }

  /// Filter providers by specialty
  List<ProviderModel> filterBySpecialty(String specialty) {
    return state.maybeWhen(
      data: (providers) => providers
          .where((p) => p.specialty.toLowerCase().contains(specialty.toLowerCase()))
          .toList(),
      orElse: () => <ProviderModel>[],
    );
  }

  /// Filter providers by online status
  List<ProviderModel> getOnlineProviders() {
    return state.maybeWhen(
      data: (providers) => providers.where((p) => p.isOnline).toList(),
      orElse: () => <ProviderModel>[],
    );
  }

  /// Filter providers by rating
  List<ProviderModel> getTopRatedProviders({double minRating = 4.0}) {
    return state.maybeWhen(
      data: (providers) =>
          providers.where((p) => p.rating >= minRating).toList()..sort(
            (a, b) => b.rating.compareTo(a.rating),
          ),
      orElse: () => <ProviderModel>[],
    );
  }

  /// Search providers by name or specialty
  List<ProviderModel> searchProviders(String query) {
    final lowerQuery = query.toLowerCase();
    return state.maybeWhen(
      data: (providers) => providers
          .where((p) =>
              p.name.toLowerCase().contains(lowerQuery) ||
              p.specialty.toLowerCase().contains(lowerQuery) ||
              p.specialtyAmharic.toLowerCase().contains(lowerQuery))
          .toList(),
      orElse: () => <ProviderModel>[],
    );
  }

  /// Get provider by ID
  ProviderModel? getProviderById(String id) {
    return state.maybeWhen(
      data: (providers) => providers.cast<ProviderModel?>().firstWhere(
            (p) => p?.id == id,
            orElse: () => null,
          ),
      orElse: () => null,
    );
  }

  /// Toggle provider online status (for demo/testing)
  void toggleProviderStatus(String providerId) {
    final currentProviders = state.maybeWhen(
      data: (providers) => providers,
      orElse: () => <ProviderModel>[],
    );

    final updatedProviders = currentProviders.map((provider) {
      if (provider.id == providerId) {
        return ProviderModel(
          id: provider.id,
          name: provider.name,
          emoji: provider.emoji,
          specialty: provider.specialty,
          specialtyAmharic: provider.specialtyAmharic,
          rating: provider.rating,
          distanceKm: provider.distanceKm,
          jobsCount: provider.jobsCount,
          hourlyRateEtb: provider.hourlyRateEtb,
          isOnline: !provider.isOnline,
          verificationStatus: provider.verificationStatus,
          bio: provider.bio,
          skills: provider.skills,
        );
      }
      return provider;
    }).toList();

    state = AsyncValue.data(updatedProviders);
  }
}

// Global providers list notifier
final providersListProvider = StateNotifierProvider<ProvidersListNotifier,
    AsyncValue<List<ProviderModel>>>((ref) {
  return ProvidersListNotifier();
});

// Derived provider: all providers
final allProvidersProvider = Provider<List<ProviderModel>>((ref) {
  final providers = ref.watch(providersListProvider);
  return providers.maybeWhen(
    data: (providers) => providers,
    orElse: () => <ProviderModel>[],
  );
});

// Derived provider: online providers only
final onlineProvidersProvider = Provider<List<ProviderModel>>((ref) {
  final providers = ref.watch(providersListProvider);
  return providers.maybeWhen(
    data: (providers) => providers.where((p) => p.isOnline).toList(),
    orElse: () => <ProviderModel>[],
  );
});

// Derived provider: top rated providers (4.5+ stars)
final topRatedProvidersProvider = Provider<List<ProviderModel>>((ref) {
  final providers = ref.watch(providersListProvider);
  return providers.maybeWhen(
    data: (providers) {
      final filtered = providers.where((p) => p.rating >= 4.5).toList();
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
      return filtered;
    },
    orElse: () => <ProviderModel>[],
  );
});

// Search provider (StateNotifier for search query)
class SearchNotifier extends StateNotifier<String> {
  SearchNotifier() : super('');

  void setSearchQuery(String query) {
    state = query;
  }

  void clearSearch() {
    state = '';
  }
}

final searchQueryProvider = StateNotifierProvider<SearchNotifier, String>((ref) {
  return SearchNotifier();
});

// Derived provider: search results
final searchResultsProvider = Provider<List<ProviderModel>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final allProviders = ref.watch(providersListProvider);

  if (query.isEmpty) return [];

  final lowerQuery = query.toLowerCase();
  return allProviders.maybeWhen(
    data: (providers) => providers
        .where((p) =>
            p.name.toLowerCase().contains(lowerQuery) ||
            p.specialty.toLowerCase().contains(lowerQuery) ||
            p.specialtyAmharic.toLowerCase().contains(lowerQuery))
        .toList(),
    orElse: () => <ProviderModel>[],
  );
});

// Derived provider: provider by ID
final providerByIdProvider = Provider.family<ProviderModel?, String>((ref, id) {
  final providers = ref.watch(providersListProvider);
  return providers.maybeWhen(
    data: (providers) => providers.cast<ProviderModel?>().firstWhere(
          (p) => p?.id == id,
          orElse: () => null,
        ),
    orElse: () => null,
  );
});

// Customer Stats for Dashboard
class CustomerStats {
  final int totalBookings;
  final int activeBookings;
  final double totalSpentEtb;
  final double averageSavingsPercentage;
  final int favoriteProviders;

  CustomerStats({
    required this.totalBookings,
    required this.activeBookings,
    required this.totalSpentEtb,
    required this.averageSavingsPercentage,
    required this.favoriteProviders,
  });

  static CustomerStats get mockStats => CustomerStats(
    totalBookings: 24,
    activeBookings: 2,
    totalSpentEtb: 8500.00,
    averageSavingsPercentage: 15.5,
    favoriteProviders: 5,
  );
}

// Customer Stats Provider
final customerStatsProvider = Provider<CustomerStats>((ref) {
  return CustomerStats.mockStats;
});

