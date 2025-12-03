// lib/features/admin/product/presentation/screens/admin_create_product_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';

import 'package:build4front/features/auth/data/services/admin_token_store.dart';
import 'package:build4front/features/admin/product/data/services/product_api_service.dart';
import '../../data/models/create_product_request.dart';

class AdminCreateProductScreen extends StatefulWidget {
  final int ownerProjectId;

  /// Optional for now – we’ll fallback to 1 if null.
  /// TODO: استبدلي 1 بالـ itemTypeId الصح أو جيبيه من API.
  final int? itemTypeId;

  final int? currencyId;

  const AdminCreateProductScreen({
    super.key,
    required this.ownerProjectId,
    this.itemTypeId,
    this.currencyId,
  });

  @override
  State<AdminCreateProductScreen> createState() =>
      _AdminCreateProductScreenState();
}

class _AdminCreateProductScreenState extends State<AdminCreateProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _downloadUrlCtrl = TextEditingController();
  final _externalUrlCtrl = TextEditingController();
  final _buttonTextCtrl = TextEditingController(text: 'Add to cart');
  final _salePriceCtrl = TextEditingController();
  final _saleStartCtrl = TextEditingController();
  final _saleEndCtrl = TextEditingController();

  ProductTypeDto _selectedProductType = ProductTypeDto.simple;
  bool _virtualProduct = false;
  bool _downloadable = false;

  bool _isSubmitting = false;
  String? _errorMessage;

  // 🔹 Attribute rows (code from dropdown + value text)
  final List<_AttributeRow> _attributes = [];

  // 🔹 Allowed attribute codes (fixed, owner ما بيخترع اسامي جديدة)
  static const List<String> _allowedAttributeCodes = [
    'brand',
    'color',
    'size',
    'capacity',
    'material',
    'model',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _imageUrlCtrl.dispose();
    _skuCtrl.dispose();
    _downloadUrlCtrl.dispose();
    _externalUrlCtrl.dispose();
    _buttonTextCtrl.dispose();
    _salePriceCtrl.dispose();
    _saleStartCtrl.dispose();
    _saleEndCtrl.dispose();

    // مهم: نعمل dispose لكل value controllers تبع attributes
    for (final row in _attributes) {
      row.dispose();
    }

    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // 🔹 مؤقتاً: itemTypeId افتراضي لو ما نبعث من فوق
    final int itemTypeId = widget.itemTypeId ?? 1;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final price = double.parse(_priceCtrl.text.trim());
      final stock = _stockCtrl.text.trim().isEmpty
          ? null
          : int.parse(_stockCtrl.text.trim());
      final salePrice = _salePriceCtrl.text.trim().isEmpty
          ? null
          : double.parse(_salePriceCtrl.text.trim());

      // 🔹 نبني attributes من dropdown + value
      final attrs = _attributes
          .where(
            (row) =>
                row.selectedCode != null &&
                row.valueCtrl.text.trim().isNotEmpty,
          )
          .map(
            (row) => AttributeValueDto(
              code: row.selectedCode!,
              value: row.valueCtrl.text.trim(),
            ),
          )
          .toList();

      final req = CreateProductRequest(
        ownerProjectId: widget.ownerProjectId,
        itemTypeId: itemTypeId,
        currencyId: widget.currencyId,
        name: _nameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim().isEmpty
            ? null
            : _descriptionCtrl.text.trim(),
        price: price,
        stock: stock,
        // ❌ Owner ما بيضبط الـ status – منبعث null والـ backend يحط Upcoming
        status: null,
        imageUrl: _imageUrlCtrl.text.trim().isEmpty
            ? null
            : _imageUrlCtrl.text.trim(),
        sku: _skuCtrl.text.trim().isEmpty ? null : _skuCtrl.text.trim(),
        productType: _selectedProductType,
        virtualProduct: _virtualProduct,
        downloadable: _downloadable,
        downloadUrl: _downloadUrlCtrl.text.trim().isEmpty
            ? null
            : _downloadUrlCtrl.text.trim(),
        externalUrl: _externalUrlCtrl.text.trim().isEmpty
            ? null
            : _externalUrlCtrl.text.trim(),
        buttonText: _buttonTextCtrl.text.trim().isEmpty
            ? null
            : _buttonTextCtrl.text.trim(),
        salePrice: salePrice,
        // 🔹 Strings عاديين, مش DatePicker
        saleStart: _saleStartCtrl.text.trim().isEmpty
            ? null
            : _saleStartCtrl.text.trim(),
        saleEnd: _saleEndCtrl.text.trim().isEmpty
            ? null
            : _saleEndCtrl.text.trim(),
        attributes: attrs,
      );

      await _createProductApi(req);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _createProductApi(CreateProductRequest req) async {
    final token = await AdminTokenStore().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing admin token – please log in again.');
    }

    final api = ProductApiService();
    await api.create(body: req.toJson(), authToken: token);
  }

  void _addAttributeRow() {
    setState(() {
      // default code = أول كود باللستة
      _attributes.add(
        _AttributeRow(selectedCode: _allowedAttributeCodes.first),
      );
    });
  }

  void _removeAttributeRow(int index) {
    setState(() {
      _attributes[index].dispose();
      _attributes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final tokens = themeState.tokens;
    final c = tokens.colors;
    final spacing = tokens.spacing;
    final text = tokens.typography;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        title: Text(l.adminProductCreateTitle, style: text.titleMedium),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ───────── Name ─────────
                Text(l.adminProductNameLabel, style: text.titleMedium),
                SizedBox(height: spacing.xs),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(hintText: l.adminProductNameHint),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l.adminProductNameRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: spacing.md),

                // ───────── Description ─────────
                Text(l.adminProductDescriptionLabel, style: text.titleMedium),
                SizedBox(height: spacing.xs),
                TextFormField(
                  controller: _descriptionCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l.adminProductDescriptionHint,
                  ),
                ),
                SizedBox(height: spacing.md),

                // ───────── Price + Stock ─────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.adminProductPriceLabel,
                            style: text.titleMedium,
                          ),
                          SizedBox(height: spacing.xs),
                          TextFormField(
                            controller: _priceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              hintText: '120.00',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return l.adminProductPriceRequired;
                              }
                              final value = double.tryParse(v.trim());
                              if (value == null || value <= 0) {
                                return l.adminProductPriceInvalid;
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.adminProductStockLabel,
                            style: text.titleMedium,
                          ),
                          SizedBox(height: spacing.xs),
                          TextFormField(
                            controller: _stockCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '50'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.md),

                // ───────── Image URL ─────────
                Text(l.adminProductImageUrlLabel, style: text.titleMedium),
                SizedBox(height: spacing.xs),
                TextFormField(
                  controller: _imageUrlCtrl,
                  decoration: const InputDecoration(hintText: 'https://...'),
                ),
                SizedBox(height: spacing.md),

                // ───────── SKU ─────────
                Text(l.adminProductSkuLabel, style: text.titleMedium),
                SizedBox(height: spacing.xs),
                TextFormField(
                  controller: _skuCtrl,
                  decoration: const InputDecoration(hintText: 'SKU-123-ABC'),
                ),
                SizedBox(height: spacing.md),

                // ───────── Product Type ─────────
                Text(l.adminProductTypeLabel, style: text.titleMedium),
                SizedBox(height: spacing.xs),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(tokens.card.radius),
                    border: Border.all(color: c.border.withOpacity(0.4)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ProductTypeDto>(
                      value: _selectedProductType,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: ProductTypeDto.simple,
                          child: Text(l.adminProductTypeSimple),
                        ),
                        DropdownMenuItem(
                          value: ProductTypeDto.variable,
                          child: Text(l.adminProductTypeVariable),
                        ),
                        DropdownMenuItem(
                          value: ProductTypeDto.grouped,
                          child: Text(l.adminProductTypeGrouped),
                        ),
                        DropdownMenuItem(
                          value: ProductTypeDto.external,
                          child: Text(l.adminProductTypeExternal),
                        ),
                      ],
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() => _selectedProductType = val);
                      },
                    ),
                  ),
                ),
                SizedBox(height: spacing.md),

                // ───────── Toggles ─────────
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l.adminProductVirtualLabel,
                    style: text.bodyMedium,
                  ),
                  value: _virtualProduct,
                  onChanged: (v) {
                    setState(() => _virtualProduct = v);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l.adminProductDownloadableLabel,
                    style: text.bodyMedium,
                  ),
                  value: _downloadable,
                  onChanged: (v) {
                    setState(() => _downloadable = v);
                  },
                ),
                SizedBox(height: spacing.sm),

                // ───────── Download URL ─────────
                Text(l.adminProductDownloadUrlLabel, style: text.titleMedium),
                SizedBox(height: spacing.xs),
                TextFormField(
                  controller: _downloadUrlCtrl,
                  decoration: const InputDecoration(
                    hintText: 'https://download-link...',
                  ),
                ),
                SizedBox(height: spacing.md),

                // ───────── External URL ─────────
                Text(l.adminProductExternalUrlLabel, style: text.titleMedium),
                SizedBox(height: spacing.xs),
                TextFormField(
                  controller: _externalUrlCtrl,
                  decoration: const InputDecoration(
                    hintText: 'https://external-link...',
                  ),
                ),
                SizedBox(height: spacing.md),

                // ───────── Button text ─────────
                Text(l.adminProductButtonTextLabel, style: text.titleMedium),
                SizedBox(height: spacing.xs),
                TextFormField(
                  controller: _buttonTextCtrl,
                  decoration: InputDecoration(
                    hintText: l.adminProductButtonTextHint,
                  ),
                ),
                SizedBox(height: spacing.md),

                // ───────── Sale section ─────────
                Text(l.adminProductSaleSectionTitle, style: text.titleMedium),
                SizedBox(height: spacing.sm),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _salePriceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l.adminProductSalePriceLabel,
                        ),
                      ),
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _saleStartCtrl,
                        decoration: InputDecoration(
                          labelText: l.adminProductSaleStartLabel,
                          hintText: '2025-12-01T10:00:00',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.sm),
                TextFormField(
                  controller: _saleEndCtrl,
                  decoration: InputDecoration(
                    labelText: l.adminProductSaleEndLabel,
                    hintText: '2025-12-10T23:59:59',
                  ),
                ),
                SizedBox(height: spacing.lg),

                // ───────── Attributes section ─────────
                Text(l.adminProductAttributesTitle, style: text.titleMedium),
                SizedBox(height: spacing.sm),

                ..._attributes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final row = entry.value;

                  return Padding(
                    padding: EdgeInsets.only(bottom: spacing.sm),
                    child: Row(
                      children: [
                        // Dropdown للـ code
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing.sm,
                              vertical: spacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: c.surface,
                              borderRadius: BorderRadius.circular(
                                tokens.card.radius,
                              ),
                              border: Border.all(
                                color: c.border.withOpacity(0.4),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value:
                                    row.selectedCode ??
                                    _allowedAttributeCodes.first,
                                isExpanded: true,
                                items: _allowedAttributeCodes
                                    .map(
                                      (code) => DropdownMenuItem(
                                        value: code,
                                        child: Text(code),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val == null) return;
                                  setState(() {
                                    row.selectedCode = val;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        // Text للـ value
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: row.valueCtrl,
                            decoration: InputDecoration(
                              labelText: l.adminProductAttributeValueLabel,
                              hintText: 'Samsung',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeAttributeRow(index),
                          icon: Icon(Icons.delete, color: c.danger),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addAttributeRow,
                    icon: const Icon(Icons.add),
                    label: Text(l.adminProductAddAttribute),
                  ),
                ),
                SizedBox(height: spacing.lg),

                // ───────── Error message ─────────
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing.md),
                    child: Text(
                      _errorMessage!,
                      style: text.bodyMedium.copyWith(color: c.danger),
                    ),
                  ),

                // ───────── Save button ─────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l.adminProductSaveButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttributeRow {
  String? selectedCode;
  final TextEditingController valueCtrl = TextEditingController();

  _AttributeRow({this.selectedCode});

  void dispose() {
    valueCtrl.dispose();
  }
}
