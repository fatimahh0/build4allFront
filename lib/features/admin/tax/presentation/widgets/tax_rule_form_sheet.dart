import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';
import '../../domain/entities/tax_rule.dart';

class TaxRuleFormSheet extends StatefulWidget {
  final int ownerProjectId;
  final TaxRule? initial;

  const TaxRuleFormSheet({
    super.key,
    required this.ownerProjectId,
    this.initial,
  });

  @override
  State<TaxRuleFormSheet> createState() => _TaxRuleFormSheetState();
}

class _TaxRuleFormSheetState extends State<TaxRuleFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _regionCtrl;

  bool _appliesToShipping = false;
  bool _enabled = true;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;

    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _rateCtrl = TextEditingController(
      text: p != null ? p.rate.toStringAsFixed(2) : '',
    );
    _countryCtrl = TextEditingController(text: p?.countryId?.toString() ?? '');
    _regionCtrl = TextEditingController(text: p?.regionId?.toString() ?? '');

    _appliesToShipping = p?.appliesToShipping ?? false;
    _enabled = p?.enabled ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rateCtrl.dispose();
    _countryCtrl.dispose();
    _regionCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildBody() {
    final countryId = _countryCtrl.text.trim().isEmpty
        ? null
        : int.tryParse(_countryCtrl.text.trim());

    final regionId = _regionCtrl.text.trim().isEmpty
        ? null
        : int.tryParse(_regionCtrl.text.trim());

    return {
      'ownerProjectId': widget.ownerProjectId,
      'name': _nameCtrl.text.trim(),
      'rate': double.parse(_rateCtrl.text.trim()),
      'appliesToShipping': _appliesToShipping,
      'enabled': _enabled,
      if (countryId != null) 'countryId': countryId,
      if (regionId != null) 'regionId': regionId,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final c = tokens.colors;
    final spacing = tokens.spacing;
    final text = tokens.typography;
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        left: spacing.lg,
        right: spacing.lg,
        top: spacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + spacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEdit ? l.adminTaxEditRuleTitle : l.adminTaxCreateRuleTitle,
              style: text.titleMedium.copyWith(
                color: c.label,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: spacing.md),

            Text(l.adminTaxRuleNameLabel, style: text.bodyMedium),
            SizedBox(height: spacing.xs),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(hintText: l.adminTaxRuleNameHint),
              validator: (v) => v == null || v.trim().isEmpty
                  ? l.adminTaxRuleNameRequired
                  : null,
            ),
            SizedBox(height: spacing.md),

            Text(l.adminTaxRuleRateLabel, style: text.bodyMedium),
            SizedBox(height: spacing.xs),
            TextFormField(
              controller: _rateCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(hintText: l.adminTaxRuleRateHint),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l.adminTaxRuleRateRequired;
                }
                final d = double.tryParse(v.trim());
                if (d == null || d <= 0) return l.adminTaxRuleRateInvalid;
                return null;
              },
            ),
            SizedBox(height: spacing.md),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.adminTaxAppliesToShippingLabel),
              value: _appliesToShipping,
              onChanged: (v) => setState(() => _appliesToShipping = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.adminTaxEnabledLabel),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
            SizedBox(height: spacing.sm),

            Text(l.adminTaxCountryIdLabel, style: text.bodyMedium),
            SizedBox(height: spacing.xs),
            TextFormField(
              controller: _countryCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: l.adminTaxCountryIdHint),
            ),
            SizedBox(height: spacing.md),

            Text(l.adminTaxRegionIdLabel, style: text.bodyMedium),
            SizedBox(height: spacing.xs),
            TextFormField(
              controller: _regionCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: l.adminTaxRegionIdHint),
            ),
            SizedBox(height: spacing.lg),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l.adminCancel),
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      Navigator.pop(context, _buildBody());
                    },
                    child: Text(_isEdit ? l.adminUpdate : l.adminCreate),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
