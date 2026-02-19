import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';

import 'package:build4front/common/widgets/app_text_field.dart';
import 'package:build4front/common/widgets/primary_button.dart';

import '../bloc/coupon_bloc.dart';
import '../bloc/coupon_state.dart';
import '../bloc/coupon_event.dart';
import '../../domain/entities/coupon.dart';

class CouponFormSheet extends StatefulWidget {
  final Coupon? existing;

  const CouponFormSheet({super.key, this.existing});

  @override
  State<CouponFormSheet> createState() => _CouponFormSheetState();
}

class _CouponFormSheetState extends State<CouponFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _valueCtrl;
  late TextEditingController _maxUsesCtrl;
  late TextEditingController _minOrderCtrl;
  late TextEditingController _maxDiscountCtrl;

  CouponDiscountType _type = CouponDiscountType.percent;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;

    _codeCtrl = TextEditingController(text: c?.code ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _valueCtrl = TextEditingController(
      text: c != null ? c.discountValue.toString() : '',
    );
    _maxUsesCtrl = TextEditingController(text: c?.maxUses?.toString() ?? '');
    _minOrderCtrl = TextEditingController(
      text: c?.minOrderAmount?.toString() ?? '',
    );
    _maxDiscountCtrl = TextEditingController(
      text: c?.maxDiscountAmount?.toString() ?? '',
    );

    _type = c?.discountType ?? CouponDiscountType.percent;
    _active = c?.active ?? true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _valueCtrl.dispose();
    _maxUsesCtrl.dispose();
    _minOrderCtrl.dispose();
    _maxDiscountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final spacing = tokens.spacing;
    final t = Theme.of(context).textTheme;

    return BlocBuilder<CouponBloc, CouponState>(
      builder: (context, state) {
        final isSaving = state.isSaving;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            spacing.lg,
            spacing.lg,
            spacing.lg,
            MediaQuery.of(context).viewInsets.bottom + spacing.lg,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.existing == null
                        ? l10n.coupons_add
                        : l10n.coupons_edit,
                    style: t.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: spacing.lg),

                  // ✅ Code
                  AppTextField(
                    label: l10n.coupons_code,
                    controller: _codeCtrl,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.coupons_code_required;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: spacing.md),

                  // ✅ Description
                  AppTextField(
                    label: l10n.coupons_description,
                    controller: _descCtrl,
                    maxLines: 2,
                  ),
                  SizedBox(height: spacing.md),

                  // Type + value
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<CouponDiscountType>(
                          value: _type,
                          decoration: InputDecoration(
                            labelText: l10n.coupons_type,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: CouponDiscountType.percent,
                              child: Text(l10n.coupons_type_percent),
                            ),
                            DropdownMenuItem(
                              value: CouponDiscountType.fixed,
                              child: Text(l10n.coupons_type_fixed),
                            ),
                            DropdownMenuItem(
                              value: CouponDiscountType.freeShipping,
                              child: Text(l10n.coupons_type_free_shipping),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _type = val);
                          },
                        ),
                      ),
                      SizedBox(width: spacing.md),
                      Expanded(
                        flex: 2,
                        child: AppTextField(
                          label: _type == CouponDiscountType.percent
                              ? l10n.coupons_value_percent
                              : l10n.coupons_value_amount,
                          controller: _valueCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return l10n.coupons_value_required;
                            }
                            final parsed = num.tryParse(v.trim());
                            if (parsed == null || parsed <= 0) {
                              return l10n.coupons_value_invalid;
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.md),

                  // Max uses + min order
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: l10n.coupons_max_uses,
                          controller: _maxUsesCtrl,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      SizedBox(width: spacing.md),
                      Expanded(
                        child: AppTextField(
                          label: l10n.coupons_min_order_amount,
                          controller: _minOrderCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.md),

                  // Max discount
                  AppTextField(
                    label: l10n.coupons_max_discount_amount,
                    controller: _maxDiscountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  SizedBox(height: spacing.md),

                  // Active switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.coupons_active, style: t.bodyMedium),
                      Switch(
                        value: _active,
                        onChanged: (v) => setState(() => _active = v),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.lg),

                  // ✅ Save (common button)
                  PrimaryButton(
                    label: l10n.common_save,
                    isLoading: isSaving,
                    onPressed: isSaving ? null : _onSubmit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

 void _onSubmit() {
  if (!_formKey.currentState!.validate()) return;

  final existing = widget.existing;
  final bloc = context.read<CouponBloc>();

  double? parseDouble(String? v) =>
      (v == null || v.trim().isEmpty) ? null : double.tryParse(v.trim());

  int? parseInt(String? v) =>
      (v == null || v.trim().isEmpty) ? null : int.tryParse(v.trim());

  // ✅ Tenant should come from token (backend).
  // Keep existing ownerProjectId when editing, otherwise send 0 (backend overrides).
  final safeOwnerProjectId = existing?.ownerProjectId ?? 0;

  final coupon = Coupon(
    id: existing?.id ?? 0,
    ownerProjectId: safeOwnerProjectId,
    code: _codeCtrl.text.trim(),
    description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    discountType: _type,
    discountValue: double.parse(_valueCtrl.text.trim()),
    maxUses: parseInt(_maxUsesCtrl.text),
    minOrderAmount: parseDouble(_minOrderCtrl.text),
    maxDiscountAmount: parseDouble(_maxDiscountCtrl.text),
    startsAt: existing?.startsAt,
    expiresAt: existing?.expiresAt,
    active: _active,
  );

  bloc.add(CouponSaveRequested(coupon: coupon));
  Navigator.of(context).maybePop();
}

}
