import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';
import 'package:build4front/core/config/env.dart';

import 'package:build4front/features/auth/data/services/admin_token_store.dart';

import 'package:build4front/features/admin/product/data/services/product_api_service.dart';
import 'package:build4front/features/admin/product/data/models/create_product_request.dart';
import 'package:build4front/features/admin/product/domain/entities/product.dart';

import 'package:build4front/features/catalog/data/services/category_api_service.dart';
import 'package:build4front/features/catalog/data/services/item_type_api_service.dart';
import 'package:build4front/features/catalog/data/services/currency_api_service.dart';

import 'package:build4front/features/catalog/data/models/item_type_model.dart';
import 'package:build4front/features/catalog/domain/entities/item_type.dart';

class AdminCreateProductScreen extends StatefulWidget {
  final int ownerProjectId;

  /// Optional: advanced mode: explicit item type
  final int? itemTypeId;

  /// Optional: simple mode – backend will resolve/create DEFAULT ItemType for this category.
  final int? categoryId;

  /// Currency for this app (per AdminUserProject)
  final int? currencyId;

  /// If not null → we are EDITING an existing product
  final Product? initialProduct;

  const AdminCreateProductScreen({
    super.key,
    required this.ownerProjectId,
    this.itemTypeId,
    this.categoryId,
    this.currencyId,
    this.initialProduct,
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

  // Local state for sale dates (used with date picker)
  DateTime? _saleStartDate;
  DateTime? _saleEndDate;

  // Attribute rows (code from dropdown + value text)
  final List<_AttributeRow> _attributes = [];

  // Fixed attribute codes – owner cannot invent random keys.
  static const List<String> _allowedAttributeCodes = [
    'brand',
    'color',
    'size',
    'capacity',
    'material',
    'model',
  ];

  // Category + ItemType state
  List<_CategoryOption> _categories = [];
  int? _selectedCategoryId;

  List<ItemType> _itemTypes = [];
  int? _selectedItemTypeId;

  bool _loadingCategories = false;
  bool _loadingItemTypes = false;
  String? _metaError;

  // Currency
  int? _effectiveCurrencyId;
  bool _loadingCurrency = false;
  String? _currencyLabel; // e.g. "USD ($)" or "EUR"

  bool get _isEdit => widget.initialProduct != null;

  @override
  void initState() {
    super.initState();

    // Resolve currency id: screen param → env → null
    final rawCurrency = Env.currencyId.trim();
    _effectiveCurrencyId =
        widget.currencyId ??
        (rawCurrency.isNotEmpty ? int.tryParse(rawCurrency) : null);

    if (_effectiveCurrencyId != null) {
      _loadCurrency(_effectiveCurrencyId!);
    }

    // If editing, pre-fill all fields from the existing product
    if (_isEdit) {
      _applyInitialProduct(widget.initialProduct!);
    }

    _loadCategories();
  }

  void _applyInitialProduct(Product p) {
    _nameCtrl.text = p.name;
    _descriptionCtrl.text = p.description ?? '';
    _priceCtrl.text = p.price.toStringAsFixed(2);
    if (p.stock != null) {
      _stockCtrl.text = p.stock.toString();
    }
    _imageUrlCtrl.text = p.imageUrl ?? '';
    _skuCtrl.text = p.sku ?? '';

    _virtualProduct = p.virtualProduct;
    _downloadable = p.downloadable;
    _downloadUrlCtrl.text = p.downloadUrl ?? '';
    _externalUrlCtrl.text = p.externalUrl ?? '';
    _buttonTextCtrl.text = p.buttonText ?? 'Add to cart';

    _selectedProductType = _productTypeFromString(p.productType);

    if (p.salePrice != null) {
      _salePriceCtrl.text = p.salePrice!.toStringAsFixed(2);
    }
    if (p.saleStart != null) {
      _saleStartDate = p.saleStart;
      _saleStartCtrl.text = _formatDateForBackend(p.saleStart!);
    }
    if (p.saleEnd != null) {
      _saleEndDate = p.saleEnd;
      _saleEndCtrl.text = _formatDateForBackend(p.saleEnd!);
    }

    // Attributes (only allowed codes)
    _attributes.clear();
    p.attributes.forEach((code, value) {
      if (_allowedAttributeCodes.contains(code)) {
        final row = _AttributeRow(selectedCode: code);
        row.valueCtrl.text = value;
        _attributes.add(row);
      }
    });
  }

  ProductTypeDto _productTypeFromString(String s) {
    switch (s.toUpperCase()) {
      case 'VARIABLE':
        return ProductTypeDto.variable;
      case 'GROUPED':
        return ProductTypeDto.grouped;
      case 'EXTERNAL':
        return ProductTypeDto.external;
      case 'SIMPLE':
      default:
        return ProductTypeDto.simple;
    }
  }

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

    for (final row in _attributes) {
      row.dispose();
    }

    super.dispose();
  }

  // ───────────────────────────────
  // Helpers
  // ───────────────────────────────

  String _formatDateForBackend(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day'
        'T00:00:00';
  }

  Future<void> _pickSaleStartDate() async {
    final now = DateTime.now();
    final initial = _saleStartDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _saleStartDate = picked;
        _saleStartCtrl.text = _formatDateForBackend(picked);
      });
    }
  }

  Future<void> _pickSaleEndDate() async {
    final now = DateTime.now();
    final initial = _saleEndDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _saleEndDate = picked;
        _saleEndCtrl.text = _formatDateForBackend(picked);
      });
    }
  }

  // ───────────────────────────────
  // Currency
  // ───────────────────────────────

  Future<void> _loadCurrency(int id) async {
    setState(() {
      _loadingCurrency = true;
    });

    try {
      final api = CurrencyApiService();
      final data = await api.getCurrencyById(id);

      final code = (data['code'] ?? '').toString();
      final symbol = (data['symbol'] ?? '').toString();
      final type = (data['currencyType'] ?? '').toString();

      String label = '';
      if (code.isNotEmpty && symbol.isNotEmpty) {
        label = '$code ($symbol)';
      } else if (code.isNotEmpty) {
        label = code;
      } else if (type.isNotEmpty) {
        label = type;
      }

      setState(() {
        _currencyLabel = label.isEmpty ? null : label;
      });
    } catch (_) {
      // keep label null on error
    } finally {
      if (mounted) {
        setState(() => _loadingCurrency = false);
      }
    }
  }

  // ───────────────────────────────
  // Load categories & item types
  // ───────────────────────────────

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCategories = true;
      _metaError = null;
    });

    try {
      final projectId = int.tryParse(Env.projectId) ?? 0;
      if (projectId <= 0) {
        throw Exception('PROJECT_ID is not configured for this app.');
      }

      final api = CategoryApiService();
      final rawList = await api.getCategoriesByProject(projectId);
      final cats = rawList.map(_CategoryOption.fromJson).toList();

      int? initialCategoryId;
      final p = widget.initialProduct;

      if (p != null &&
          p.categoryId != null &&
          cats.any((c) => c.id == p.categoryId)) {
        initialCategoryId = p.categoryId;
      } else if (widget.categoryId != null &&
          cats.any((c) => c.id == widget.categoryId)) {
        initialCategoryId = widget.categoryId;
      } else if (cats.isNotEmpty) {
        initialCategoryId = cats.first.id;
      }

      setState(() {
        _categories = cats;
        _selectedCategoryId = initialCategoryId;
      });

      if (initialCategoryId != null) {
        await _loadItemTypesForCategory(initialCategoryId);
      }
    } catch (e) {
      setState(() {
        _metaError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loadingCategories = false);
      }
    }
  }

  Future<void> _loadItemTypesForCategory(int categoryId) async {
    setState(() {
      _loadingItemTypes = true;
      _metaError = null;
    });

    try {
      final api = ItemTypeApiService();
      final rawList = await api.getItemTypesByCategory(categoryId);
      final types = rawList
          .map((m) => ItemTypeModel.fromJson(m).toEntity())
          .toList();

      int? initialTypeId;
      final p = widget.initialProduct;

      if (p != null &&
          p.itemTypeId != null &&
          types.any((t) => t.id == p.itemTypeId)) {
        initialTypeId = p.itemTypeId;
      } else if (widget.itemTypeId != null &&
          types.any((t) => t.id == widget.itemTypeId)) {
        initialTypeId = widget.itemTypeId;
      } else if (types.isNotEmpty) {
        initialTypeId = types.first.id;
      }

      setState(() {
        _itemTypes = types;
        _selectedItemTypeId = initialTypeId;
      });
    } catch (e) {
      setState(() {
        _metaError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loadingItemTypes = false);
      }
    }
  }

  // ───────────────────────────────
  // Create new Category / ItemType
  // ───────────────────────────────

  Future<void> _showCreateCategoryDialog() async {
    final ctrl = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New category'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Ex: Laptops'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final v = ctrl.text.trim();
              if (v.isEmpty) return;
              Navigator.of(ctx).pop(v);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null || result.trim().isEmpty) return;

    await _createCategory(result.trim());
  }

  Future<void> _createCategory(String name) async {
    try {
      final token = await AdminTokenStore().getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Missing admin token – please log in again.');
      }

      final projectId = int.tryParse(Env.projectId) ?? 0;
      if (projectId <= 0) {
        throw Exception('PROJECT_ID is not configured for this app.');
      }

      final api = CategoryApiService();
      final data = await api.createCategory(
        name: name,
        projectId: projectId,
        authToken: token,
      );

      final cat = _CategoryOption.fromJson(data);

      setState(() {
        _categories = [..._categories, cat];
        _selectedCategoryId = cat.id;
        _metaError = null; // clear old errors on success
      });

      await _loadItemTypesForCategory(cat.id);
    } catch (e) {
      setState(() {
        _metaError = e.toString();
      });
    }
  }

  Future<void> _showCreateItemTypeDialog() async {
    if (_selectedCategoryId == null) {
      setState(() {
        _metaError = 'Please select a category before creating item type.';
      });
      return;
    }

    final ctrl = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New item type'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Ex: Laptop'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final v = ctrl.text.trim();
              if (v.isEmpty) return;
              Navigator.of(ctx).pop(v);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null || result.trim().isEmpty) return;

    await _createItemType(result.trim());
  }

  Future<void> _createItemType(String name) async {
    final categoryId = _selectedCategoryId;
    if (categoryId == null) {
      setState(() {
        _metaError = 'Please select a category before creating item type.';
      });
      return;
    }

    try {
      final token = await AdminTokenStore().getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Missing admin token – please log in again.');
      }

      final api = ItemTypeApiService();
      final data = await api.createItemType(
        name: name,
        categoryId: categoryId,
        authToken: token,
      );

      final newType = ItemTypeModel.fromJson(data).toEntity();

      setState(() {
        _itemTypes = [..._itemTypes, newType];
        _selectedItemTypeId = newType.id;
      });
    } catch (e) {
      setState(() {
        _metaError = e.toString();
      });
    }
  }

  // ───────────────────────────────
  // Submit (create OR update)
  // ───────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedCategoryId = _selectedCategoryId ?? widget.categoryId;
    if (selectedCategoryId == null) {
      setState(() {
        _errorMessage = 'Please select a category before saving the product.';
      });
      return;
    }

    final currencyId = widget.currencyId ?? _effectiveCurrencyId;
    if (currencyId == null) {
      setState(() {
        _errorMessage =
            'Missing currency for this app. Please configure currency first.';
      });
      return;
    }

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

      final int? itemTypeId = _selectedItemTypeId ?? widget.itemTypeId;

      // Common values used by both create & update
      final String? description = _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim();
      final String? imageUrl = _imageUrlCtrl.text.trim().isEmpty
          ? null
          : _imageUrlCtrl.text.trim();
      final String? sku = _skuCtrl.text.trim().isEmpty
          ? null
          : _skuCtrl.text.trim();

      final String? downloadUrl =
          _downloadable && _downloadUrlCtrl.text.trim().isNotEmpty
          ? _downloadUrlCtrl.text.trim()
          : null;

      final String? externalUrl =
          _selectedProductType == ProductTypeDto.external &&
              _externalUrlCtrl.text.trim().isNotEmpty
          ? _externalUrlCtrl.text.trim()
          : null;

      final String? buttonText =
          _selectedProductType == ProductTypeDto.external &&
              _buttonTextCtrl.text.trim().isNotEmpty
          ? _buttonTextCtrl.text.trim()
          : null;

      final String? saleStartText = _saleStartCtrl.text.trim().isEmpty
          ? null
          : _saleStartCtrl.text.trim();
      final String? saleEndText = _saleEndCtrl.text.trim().isEmpty
          ? null
          : _saleEndCtrl.text.trim();

      if (!_isEdit) {
        // CREATE
        final req = CreateProductRequest(
          ownerProjectId: widget.ownerProjectId,
          itemTypeId: itemTypeId,
          categoryId: selectedCategoryId,
          currencyId: currencyId,
          name: _nameCtrl.text.trim(),
          description: description,
          price: price,
          stock: stock,
          status: null, // backend will set "Upcoming"
          imageUrl: imageUrl,
          sku: sku,
          productType: _selectedProductType,
          virtualProduct: _virtualProduct,
          downloadable: _downloadable,
          downloadUrl: downloadUrl,
          externalUrl: externalUrl,
          buttonText: buttonText,
          salePrice: salePrice,
          saleStart: saleStartText,
          saleEnd: saleEndText,
          attributes: attrs,
        );

        await _createProductApi(req);
      } else {
        // UPDATE
        await _updateProductApi(
          productId: widget.initialProduct!.id,
          ownerProjectId: widget.ownerProjectId,
          categoryId: selectedCategoryId,
          itemTypeId: itemTypeId,
          currencyId: currencyId,
          name: _nameCtrl.text.trim(),
          description: description,
          price: price,
          stock: stock,
          imageUrl: imageUrl,
          sku: sku,
          productType: _selectedProductType,
          virtualProduct: _virtualProduct,
          downloadable: _downloadable,
          downloadUrl: downloadUrl,
          externalUrl: externalUrl,
          buttonText: buttonText,
          salePrice: salePrice,
          saleStart: saleStartText,
          saleEnd: saleEndText,
          attributes: attrs,
        );
      }

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

  Future<void> _updateProductApi({
    required int productId,
    required int ownerProjectId,
    required int? categoryId,
    required int? itemTypeId,
    required int? currencyId,
    required String name,
    String? description,
    required double price,
    int? stock,
    String? imageUrl,
    String? sku,
    required ProductTypeDto productType,
    required bool virtualProduct,
    required bool downloadable,
    String? downloadUrl,
    String? externalUrl,
    String? buttonText,
    double? salePrice,
    String? saleStart,
    String? saleEnd,
    required List<AttributeValueDto> attributes,
  }) async {
    final token = await AdminTokenStore().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing admin token – please log in again.');
    }

    final api = ProductApiService();

    final body = <String, dynamic>{
      'ownerProjectId': ownerProjectId,
      if (categoryId != null) 'categoryId': categoryId,
      if (itemTypeId != null) 'itemTypeId': itemTypeId,
      'currencyId': currencyId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      // status NOT sent → backend keeps existing
      'imageUrl': imageUrl,
      'sku': sku,
      'productType': productTypeDtoToApi(productType),
      'virtualProduct': virtualProduct,
      'downloadable': downloadable,
      'downloadUrl': downloadUrl,
      'externalUrl': externalUrl,
      'buttonText': buttonText,
      'salePrice': salePrice,
      'saleStart': saleStart,
      'saleEnd': saleEnd,
      if (attributes.isNotEmpty)
        'attributes': attributes.map((e) => e.toJson()).toList(),
    };

    await api.update(id: productId, body: body, authToken: token);
  }

  void _addAttributeRow() {
    setState(() {
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

  // ───────────────────────────────
  // UI
  // ───────────────────────────────

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
        title: Text(
          // reuse same key for now
          l.adminProductCreateTitle,
          style: text.titleMedium,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- name ---
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

                // --- description ---
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

                // --- Category + ItemType (same as before) ---
                Text('Category', style: text.titleMedium),
                SizedBox(height: spacing.xs),
                if (_loadingCategories)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_categories.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No categories found for this project.',
                        style: text.bodyMedium.copyWith(color: c.danger),
                      ),
                      TextButton.icon(
                        onPressed: _showCreateCategoryDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add category'),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
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
                            child: DropdownButton<int>(
                              value: _selectedCategoryId,
                              isExpanded: true,
                              items: _categories
                                  .map(
                                    (cat) => DropdownMenuItem<int>(
                                      value: cat.id,
                                      child: Text(cat.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) async {
                                if (val == null) return;
                                setState(() {
                                  _selectedCategoryId = val;
                                  _selectedItemTypeId = null;
                                });
                                await _loadItemTypesForCategory(val);
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: spacing.sm),
                      IconButton(
                        onPressed: _showCreateCategoryDialog,
                        icon: const Icon(Icons.add),
                        color: c.primary,
                      ),
                    ],
                  ),
                SizedBox(height: spacing.md),

                if (_selectedCategoryId != null) ...[
                  Text('Item type', style: text.titleMedium),
                  SizedBox(height: spacing.xs),
                  if (_loadingItemTypes)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_itemTypes.isEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No item types for this category.',
                          style: text.bodyMedium.copyWith(color: c.danger),
                        ),
                        TextButton.icon(
                          onPressed: _showCreateItemTypeDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add item type'),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
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
                              child: DropdownButton<int>(
                                value: _selectedItemTypeId,
                                isExpanded: true,
                                items: _itemTypes
                                    .map(
                                      (t) => DropdownMenuItem<int>(
                                        value: t.id,
                                        child: Text(t.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val == null) return;
                                  setState(() {
                                    _selectedItemTypeId = val;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        IconButton(
                          onPressed: _showCreateItemTypeDialog,
                          icon: const Icon(Icons.add),
                          color: c.primary,
                        ),
                      ],
                    ),
                  SizedBox(height: spacing.md),
                ],

                if (_metaError != null) ...[
                  Text(
                    _metaError!,
                    style: text.bodyMedium.copyWith(color: c.danger),
                  ),
                  SizedBox(height: spacing.md),
                ],

                // --- price + stock ---
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l.adminProductPriceLabel,
                                style: text.titleMedium,
                              ),
                              const SizedBox(width: 6),
                              if (_loadingCurrency)
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else if (_currencyLabel != null)
                                Text(
                                  ' (${_currencyLabel!})',
                                  style: text.bodySmall.copyWith(
                                    color: c.muted.withOpacity(0.8),
                                  ),
                                ),
                            ],
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

                // --- image URL ---
                Text(l.adminProductImageUrlLabel, style: text.titleMedium),
                SizedBox(height: spacing.xs),
                TextFormField(
                  controller: _imageUrlCtrl,
                  decoration: const InputDecoration(hintText: 'https://...'),
                ),
                SizedBox(height: spacing.md),

                // --- SKU ---
                Text(l.adminProductSkuLabel, style: text.titleMedium),
                SizedBox(height: spacing.xs),
                TextFormField(
                  controller: _skuCtrl,
                  decoration: const InputDecoration(hintText: 'SKU-123-ABC'),
                ),
                SizedBox(height: spacing.md),

                // --- Product type ---
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
                        setState(() {
                          _selectedProductType = val;
                          if (val != ProductTypeDto.external) {
                            _externalUrlCtrl.clear();
                            _buttonTextCtrl.clear();
                          }
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: spacing.md),

                // --- Toggles ---
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
                    setState(() {
                      _downloadable = v;
                      if (!v) {
                        _downloadUrlCtrl.clear();
                      }
                    });
                  },
                ),
                SizedBox(height: spacing.sm),

                if (_downloadable) ...[
                  Text(l.adminProductDownloadUrlLabel, style: text.titleMedium),
                  SizedBox(height: spacing.xs),
                  TextFormField(
                    controller: _downloadUrlCtrl,
                    decoration: const InputDecoration(
                      hintText: 'https://download-link...',
                    ),
                  ),
                  SizedBox(height: spacing.md),
                ],

                if (_selectedProductType == ProductTypeDto.external) ...[
                  Text(l.adminProductExternalUrlLabel, style: text.titleMedium),
                  SizedBox(height: spacing.xs),
                  TextFormField(
                    controller: _externalUrlCtrl,
                    decoration: const InputDecoration(
                      hintText: 'https://external-link...',
                    ),
                  ),
                  SizedBox(height: spacing.md),

                  Text(l.adminProductButtonTextLabel, style: text.titleMedium),
                  SizedBox(height: spacing.xs),
                  TextFormField(
                    controller: _buttonTextCtrl,
                    decoration: InputDecoration(
                      hintText: l.adminProductButtonTextHint,
                    ),
                  ),
                  SizedBox(height: spacing.md),
                ],

                // --- Sale section ---
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
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: l.adminProductSaleStartLabel,
                          hintText: 'YYYY-MM-DD',
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        onTap: _pickSaleStartDate,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.sm),

                TextFormField(
                  controller: _saleEndCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: l.adminProductSaleEndLabel,
                    hintText: 'YYYY-MM-DD',
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  onTap: _pickSaleEndDate,
                ),
                SizedBox(height: spacing.lg),

                // --- Attributes ---
                Text(l.adminProductAttributesTitle, style: text.titleMedium),
                SizedBox(height: spacing.sm),

                ..._attributes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final row = entry.value;

                  return Padding(
                    padding: EdgeInsets.only(bottom: spacing.sm),
                    child: Row(
                      children: [
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

                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing.md),
                    child: Text(
                      _errorMessage!,
                      style: text.bodyMedium.copyWith(color: c.danger),
                    ),
                  ),

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

// ───────────────────────────────
// Helpers
// ───────────────────────────────

class _AttributeRow {
  String? selectedCode;
  final TextEditingController valueCtrl = TextEditingController();

  _AttributeRow({this.selectedCode});

  void dispose() {
    valueCtrl.dispose();
  }
}

class _CategoryOption {
  final int id;
  final String name;

  _CategoryOption({required this.id, required this.name});

  factory _CategoryOption.fromJson(Map<String, dynamic> j) {
    return _CategoryOption(
      id: (j['id'] ?? 0) is int ? j['id'] as int : int.parse('${j['id']}'),
      name: (j['name'] ?? '').toString(),
    );
  }
}
