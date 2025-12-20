import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';
import 'package:build4front/common/widgets/app_text_field.dart';
import 'package:build4front/common/widgets/app_search_field.dart';

import 'package:build4front/features/catalog/data/models/country_model.dart';
import 'package:build4front/features/catalog/data/models/region_model.dart';
import 'package:build4front/features/catalog/data/services/catalog_api_service.dart';
import 'package:build4front/features/auth/data/services/auth_token_store.dart';
import 'package:build4front/features/checkout/domain/entities/checkout_entities.dart';

class CheckoutAddressForm extends StatefulWidget {
  final ShippingAddress initial;
  final ValueChanged<ShippingAddress> onApply;

  const CheckoutAddressForm({
    super.key,
    required this.initial,
    required this.onApply,
  });

  @override
  State<CheckoutAddressForm> createState() => _CheckoutAddressFormState();
}

class _CheckoutAddressFormState extends State<CheckoutAddressForm> {
  final _catalogApi = CatalogApiService();
  final _tokenStore = AuthTokenStore();

  bool _loadingCatalog = true;
  String? _catalogError;

  List<CountryModel> _countries = [];
  List<RegionModel> _allRegions = [];

  CountryModel? _selectedCountry;
  RegionModel? _selectedRegion;

  late final TextEditingController _cityCtrl;
  late final TextEditingController _postalCtrl;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _cityCtrl = TextEditingController(text: widget.initial.city ?? '');
    _postalCtrl = TextEditingController(text: widget.initial.postalCode ?? '');

    _cityCtrl.addListener(_debouncedNotify);
    _postalCtrl.addListener(_debouncedNotify);

    _bootstrapCatalog(
      initialCountryId: widget.initial.countryId,
      initialRegionId: widget.initial.regionId,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  void _debouncedNotify() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _notifyParent);
  }

  void _notifyParent() {
    widget.onApply(
      ShippingAddress(
        countryId: _selectedCountry?.id,
        regionId: _selectedRegion?.id,
        city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        postalCode: _postalCtrl.text.trim().isEmpty
            ? null
            : _postalCtrl.text.trim(),
      ),
    );
  }

  // ✅ helper: find Lebanon from API list
  CountryModel? _findLebanon(List<CountryModel> countries) {
    // Prefer ISO2 "LB", fallback by name match
    return countries
            .where((c) => (c.iso2Code).toUpperCase() == 'LB')
            .firstOrNull ??
        countries
            .where((c) => c.name.toLowerCase().trim() == 'lebanon')
            .firstOrNull ??
        countries
            .where((c) => c.name.toLowerCase().contains('lebanon'))
            .firstOrNull;
  }

  Future<void> _bootstrapCatalog({
    int? initialCountryId,
    int? initialRegionId,
  }) async {
    try {
      final token = await _tokenStore.getToken();
      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;

      if (token == null || token.isEmpty) {
        setState(() {
          _loadingCatalog = false;
          _catalogError = l10n.missingUserToken;
        });
        return;
      }

      final countries = await _catalogApi.listCountries(authToken: token);
      final regions = await _catalogApi.listRegions(authToken: token);

      CountryModel? initCountry;
      RegionModel? initRegion;

      // 1) try saved IDs
      if (initialCountryId != null) {
        initCountry = countries
            .where((c) => c.id == initialCountryId)
            .firstOrNull;
      }
      if (initialRegionId != null) {
        initRegion = regions.where((r) => r.id == initialRegionId).firstOrNull;
      }
      if (initCountry == null && initRegion != null) {
        initCountry = countries
            .where((c) => c.id == initRegion!.countryId)
            .firstOrNull;
      }

      // ✅ 2) default to Lebanon if still null
      initCountry ??= _findLebanon(countries);

      // ✅ 3) if region doesn't match selected country, reset it
      if (initRegion != null && initCountry != null) {
        if (initRegion.countryId != initCountry.id) {
          initRegion = null;
        }
      }

      setState(() {
        _countries = countries;
        _allRegions = regions;
        _selectedCountry = initCountry;
        _selectedRegion = initRegion;
        _loadingCatalog = false;
        _catalogError = null;
      });

      _notifyParent();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCatalog = false;
        _catalogError = e.toString();
      });
    }
  }

  List<RegionModel> get _filteredRegions {
    final c = _selectedCountry;
    if (c == null) return [];
    return _allRegions.where((r) => r.countryId == c.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final spacing = tokens.spacing;
    final c = tokens.colors;
    final text = tokens.typography;

    if (_loadingCatalog) {
      return Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Center(child: CircularProgressIndicator(color: c.primary)),
      );
    }

    if (_catalogError != null) {
      return Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.checkoutAddressTitle,
              style: text.titleMedium.copyWith(color: c.label),
            ),
            SizedBox(height: spacing.sm),
            Text(
              _catalogError!,
              style: text.bodyMedium.copyWith(color: c.danger),
            ),
            SizedBox(height: spacing.sm),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _loadingCatalog = true;
                  _catalogError = null;
                });
                _bootstrapCatalog(
                  initialCountryId: widget.initial.countryId,
                  initialRegionId: widget.initial.regionId,
                );
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.adminTaxCountryLabel),
        SizedBox(height: spacing.xs),

        _SearchablePicker<CountryModel>(
          items: _countries,
          value: _selectedCountry,
          label: (x) => '${x.name} (${x.iso2Code})',
          hintText: l10n.adminTaxSelectCountryFirst,
          onChanged: (picked) {
            setState(() {
              _selectedCountry = picked;
              _selectedRegion = null;
            });
            _notifyParent();
          },
        ),

        SizedBox(height: spacing.md),

        Text(l10n.adminTaxRegionLabel),
        SizedBox(height: spacing.xs),

        _SearchablePicker<RegionModel>(
          items: _filteredRegions,
          value: _selectedRegion,
          enabled: _selectedCountry != null,
          label: (x) => x.name,
          hintText: l10n.adminShippingRegionHint,
          onChanged: (picked) {
            setState(() => _selectedRegion = picked);
            _notifyParent();
          },
        ),

        SizedBox(height: spacing.md),

        AppTextField(
          label: l10n.checkoutCityLabel,
          controller: _cityCtrl,
          hintText: l10n.checkoutCityHint,
          textInputAction: TextInputAction.next,
        ),

        SizedBox(height: spacing.sm),

        AppTextField(
          label: l10n.checkoutPostalCodeLabel,
          controller: _postalCtrl,
          hintText: l10n.checkoutPostalCodeHint,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}

/* ===== searchable picker ===== */

class _SearchablePicker<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final bool enabled;
  final String hintText;
  final String Function(T) label;
  final ValueChanged<T?> onChanged;

  const _SearchablePicker({
    required this.items,
    required this.value,
    required this.label,
    required this.hintText,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final c = tokens.colors;
    final text = tokens.typography;
    final spacing = tokens.spacing;

    final disabled = !enabled || items.isEmpty;

    return InkWell(
      onTap: disabled
          ? null
          : () async {
              final picked = await showModalBottomSheet<T>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(tokens.card.radius),
                  ),
                ),
                builder: (_) => _PickerSheet<T>(
                  items: items,
                  label: label,
                  title: hintText,
                ),
              );
              if (picked != null) onChanged(picked);
            },
      borderRadius: BorderRadius.circular(tokens.card.radius),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        decoration: BoxDecoration(
          color: enabled ? c.surface : c.surface.withOpacity(0.4),
          borderRadius: BorderRadius.circular(tokens.card.radius),
          border: Border.all(color: c.border.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                items.isEmpty
                    ? l10n.noOptions
                    : (value == null ? hintText : label(value as T)),
                style: text.bodyMedium.copyWith(
                  color: items.isEmpty
                      ? c.muted
                      : (value == null ? c.muted : c.label),
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: c.muted),
          ],
        ),
      ),
    );
  }
}

class _PickerSheet<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) label;
  final String title;

  const _PickerSheet({
    required this.items,
    required this.label,
    required this.title,
  });

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  final _searchCtrl = TextEditingController();
  late List<T> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _searchCtrl.addListener(_apply);
  }

  void _apply() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.items
          : widget.items
                .where((i) => widget.label(i).toLowerCase().contains(q))
                .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final c = tokens.colors;
    final spacing = tokens.spacing;
    final text = tokens.typography;

    final h = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // ✅ KEY FIX: give the sheet a real height + Expanded list
    // No fixed "420" anymore => no overflow when keyboard opens.
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: h * 0.78,
        child: Padding(
          padding: EdgeInsets.only(
            left: spacing.lg,
            right: spacing.lg,
            top: spacing.lg,
            bottom: spacing.lg,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: text.titleMedium.copyWith(
                        color: c.label,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),

              SizedBox(height: spacing.md),

              AppSearchField(
                hintText: l10n.searchLabel,
                controller: _searchCtrl,
              ),

              SizedBox(height: spacing.md),

              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(spacing.lg),
                          child: Text(
                            l10n.noResultsLabel,
                            style: text.bodyMedium.copyWith(color: c.muted),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: c.border.withOpacity(0.15)),
                        itemBuilder: (_, i) {
                          final item = _filtered[i];
                          return ListTile(
                            title: Text(
                              widget.label(item),
                              style: text.bodyMedium,
                            ),
                            onTap: () => Navigator.pop(context, item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
