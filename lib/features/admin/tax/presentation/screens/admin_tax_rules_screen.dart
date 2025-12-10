import 'package:build4front/features/admin/tax/domain/usecase/create_tax_rule.dart';
import 'package:build4front/features/admin/tax/domain/usecase/delete_tax_rule.dart';
import 'package:build4front/features/admin/tax/domain/usecase/list_tax_rules.dart';
import 'package:build4front/features/admin/tax/domain/usecase/update_tax_rule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';
import 'package:build4front/features/auth/data/services/admin_token_store.dart';

import '../../data/services/tax_api_service.dart';
import '../../data/repositories/tax_repository_impl.dart';

import '../bloc/tax_rules_bloc.dart';
import '../bloc/tax_rules_event.dart';
import '../bloc/tax_rules_state.dart';
import '../widgets/tax_rule_form_sheet.dart';

class AdminTaxRulesScreen extends StatelessWidget {
  final int ownerProjectId;

  const AdminTaxRulesScreen({super.key, required this.ownerProjectId});

  @override
  Widget build(BuildContext context) {
    final repo = TaxRepositoryImpl(TaxApiService());

    return BlocProvider(
      create: (_) => TaxRulesBloc(
        listRules: ListTaxRules(repo),
        createRule: CreateTaxRule(repo),
        updateRule: UpdateTaxRule(repo),
        deleteRule: DeleteTaxRule(repo),
      ),
      child: _AdminTaxRulesView(ownerProjectId: ownerProjectId),
    );
  }
}

class _AdminTaxRulesView extends StatefulWidget {
  final int ownerProjectId;
  const _AdminTaxRulesView({required this.ownerProjectId});

  @override
  State<_AdminTaxRulesView> createState() => _AdminTaxRulesViewState();
}

class _AdminTaxRulesViewState extends State<_AdminTaxRulesView> {
  final _store = AdminTokenStore();
  String? _token;
  bool _loadingToken = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await _store.getToken();
    if (!mounted) return;

    setState(() {
      _token = t;
      _loadingToken = false;
    });

    if (t != null && t.isNotEmpty) {
      context.read<TaxRulesBloc>().add(
        LoadTaxRules(ownerProjectId: widget.ownerProjectId, token: t),
      );
    }
  }

  void _showNoTokenMessage() {
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.adminSessionExpired)));
  }

  Future<void> _openCreateSheet() async {
    if (_loadingToken) return;

    if (_token == null || _token!.isEmpty) {
      _showNoTokenMessage();
      return;
    }

    final body = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaxRuleFormSheet(ownerProjectId: widget.ownerProjectId),
    );

    if (body == null) return;

    context.read<TaxRulesBloc>().add(
      CreateTaxRuleEvent(
        body: body,
        token: _token!,
        ownerProjectId: widget.ownerProjectId,
      ),
    );
  }

  Future<void> _openEditSheet(dynamic rule) async {
    if (_loadingToken) return;

    if (_token == null || _token!.isEmpty) {
      _showNoTokenMessage();
      return;
    }

    final body = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaxRuleFormSheet(
        ownerProjectId: widget.ownerProjectId,
        initial: rule,
      ),
    );

    if (body == null) return;

    context.read<TaxRulesBloc>().add(
      UpdateTaxRuleEvent(
        id: rule.id,
        body: body,
        token: _token!,
        ownerProjectId: widget.ownerProjectId,
      ),
    );
  }

  void _deleteRule(int id) {
    if (_loadingToken) return;

    if (_token == null || _token!.isEmpty) {
      _showNoTokenMessage();
      return;
    }

    context.read<TaxRulesBloc>().add(
      DeleteTaxRuleEvent(
        id: id,
        token: _token!,
        ownerProjectId: widget.ownerProjectId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final c = tokens.colors;
    final spacing = tokens.spacing;
    final text = tokens.typography;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        title: Text(
          l.adminTaxRulesTitle,
          style: text.titleMedium.copyWith(color: c.label),
        ),
        actions: [
          IconButton(
            onPressed: (_loadingToken || _token == null || _token!.isEmpty)
                ? null
                : _openCreateSheet,
            icon: const Icon(Icons.add),
            tooltip: l.adminTaxAddRule,
          ),
        ],
      ),
      body: BlocBuilder<TaxRulesBloc, TaxRulesState>(
        builder: (context, state) {
          if (_loadingToken) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_token == null || _token!.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(spacing.lg),
                child: Text(
                  l.adminSessionExpired,
                  style: text.bodyMedium.copyWith(color: c.danger),
                ),
              ),
            );
          }

          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(spacing.lg),
                child: Text(
                  state.error!,
                  style: text.bodyMedium.copyWith(color: c.danger),
                ),
              ),
            );
          }

          if (state.rules.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(spacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.adminTaxNoRules,
                      style: text.bodyMedium.copyWith(color: c.muted),
                    ),
                    SizedBox(height: spacing.md),
                    ElevatedButton.icon(
                      onPressed: _openCreateSheet,
                      icon: const Icon(Icons.add),
                      label: Text(l.adminTaxAddRule),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(spacing.lg),
            itemCount: state.rules.length,
            separatorBuilder: (_, __) => SizedBox(height: spacing.sm),
            itemBuilder: (_, i) {
              final r = state.rules[i];

              return Container(
                padding: EdgeInsets.all(spacing.md),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(tokens.card.radius),
                  border: Border.all(color: c.border.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name,
                            style: text.titleMedium.copyWith(color: c.label),
                          ),
                          SizedBox(height: spacing.xs),
                          Text(
                            '${l.adminTaxRateShort}: ${r.rate.toStringAsFixed(2)}%',
                            style: text.bodySmall.copyWith(color: c.muted),
                          ),
                          Text(
                            '${l.adminTaxAppliesToShippingShort}: ${r.appliesToShipping ? l.yes : l.no}',
                            style: text.bodySmall.copyWith(color: c.muted),
                          ),
                          Text(
                            '${l.adminTaxEnabledShort}: ${r.enabled ? l.yes : l.no}',
                            style: text.bodySmall.copyWith(color: c.muted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _openEditSheet(r),
                      icon: Icon(Icons.edit, color: c.primary),
                      tooltip: l.adminEdit,
                    ),
                    IconButton(
                      onPressed: () => _deleteRule(r.id),
                      icon: Icon(Icons.delete, color: c.danger),
                      tooltip: l.adminDelete,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
