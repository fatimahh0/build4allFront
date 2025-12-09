import 'package:equatable/equatable.dart';
import '../../domain/entities/tax_rule.dart';

class TaxRulesState extends Equatable {
  final bool loading;
  final bool submitting;
  final List<TaxRule> rules;
  final String? error;

  const TaxRulesState({
    required this.loading,
    required this.submitting,
    required this.rules,
    this.error,
  });

  factory TaxRulesState.initial() => const TaxRulesState(
    loading: false,
    submitting: false,
    rules: [],
    error: null,
  );

  TaxRulesState copyWith({
    bool? loading,
    bool? submitting,
    List<TaxRule>? rules,
    String? error,
    bool clearError = false,
  }) {
    return TaxRulesState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      rules: rules ?? this.rules,
      error: clearError ? null : error,
    );
  }

  @override
  List<Object?> get props => [loading, submitting, rules, error];
}
