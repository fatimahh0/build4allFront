import 'dart:async';

import 'package:build4front/core/network/globals.dart' as net;
import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/features/home/homebanner/domain/data/services/home_banners_api_service.dart';
import 'package:build4front/features/home/homebanner/domain/entities/home_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBannerSlider extends StatefulWidget {
  final int ownerProjectId;
  final String token;

  /// Optional: what happens when user taps a banner (open product / category / URL)
  final void Function(HomeBanner banner)? onBannerTap;

  const HomeBannerSlider({
    super.key,
    required this.ownerProjectId,
    required this.token,
    this.onBannerTap,
  });

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  late final HomeBannersApiService _service;
  late final PageController _pageController;

  List<HomeBanner> _banners = [];
  bool _isLoading = true;
  String? _error;
  int _currentIndex = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _service = HomeBannersApiService.create();
    _pageController = PageController();
    _load();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await _service.fetchActiveBanners(
        ownerProjectId: widget.ownerProjectId,
        token: widget.token,
      );

      if (!mounted) return;

      setState(() {
        _banners = list;
        _isLoading = false;
      });

      _setupAutoSlide();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _setupAutoSlide() {
    _autoSlideTimer?.cancel();
    if (_banners.length <= 1) return;

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || _banners.isEmpty) return;

      final nextIndex = (_currentIndex + 1) % _banners.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final themeState = context.read<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;

    if (_isLoading) {
      return Container(
        margin: EdgeInsets.only(bottom: spacing.lg),
        height: 170,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Container(
        margin: EdgeInsets.only(bottom: spacing.lg),
        padding: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          color: c.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: c.onErrorContainer),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Text(
                'Failed to load banners',
                style: t.bodyMedium?.copyWith(color: c.onErrorContainer),
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: c.onErrorContainer),
              onPressed: _load,
            ),
          ],
        ),
      );
    }

    if (_banners.isEmpty) {
      // No banners: return empty to not break layout
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: spacing.lg),
      height: 170,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (index) {
              if (!mounted) return;
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = _banners[index];

              // ✅ حوّل الـ imageUrl النسبي لـ URL كامل
              final resolvedImageUrl = net.resolveUrl(banner.imageUrl);

              return GestureDetector(
                onTap: () => widget.onBannerTap?.call(banner),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        resolvedImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: c.surfaceVariant,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: c.onSurfaceVariant,
                            size: 32,
                          ),
                        ),
                      ),
                      // gradient overlay bottom
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.05),
                              Colors.black.withOpacity(0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // text
                      Positioned(
                        left: spacing.lg,
                        right: spacing.lg,
                        bottom: spacing.lg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (banner.title != null &&
                                banner.title!.trim().isNotEmpty)
                              Text(
                                banner.title!,
                                style: t.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            if (banner.subtitle != null &&
                                banner.subtitle!.trim().isNotEmpty) ...[
                              SizedBox(height: spacing.xs),
                              Text(
                                banner.subtitle!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: t.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // dots indicator
          Positioned(
            bottom: spacing.sm,
            right: spacing.lg,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_banners.length, (index) {
                final isActive = index == _currentIndex;
                return Container(
                  margin: EdgeInsets.only(left: index == 0 ? 0 : 4),
                  width: isActive ? 10 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
