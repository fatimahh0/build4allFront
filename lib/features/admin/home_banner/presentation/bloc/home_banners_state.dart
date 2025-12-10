import '../../domain/entities/home_banner.dart';

class HomeBannersState {
  final bool loading;
  final String? error;
  final List<HomeBanner> banners;

  const HomeBannersState({
    this.loading = false,
    this.error,
    this.banners = const [],
  });

  HomeBannersState copyWith({
    bool? loading,
    String? error,
    List<HomeBanner>? banners,
  }) {
    return HomeBannersState(
      loading: loading ?? this.loading,
      error: error,
      banners: banners ?? this.banners,
    );
  }
}
