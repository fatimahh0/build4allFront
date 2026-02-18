import 'package:equatable/equatable.dart';
import '../../domain/entities/tax_rule.dart';

abstract class TaxRulesEvent extends Equatable {
  const TaxRulesEvent();
  @override
  List<Object?> get props => [];
}

class LoadTaxRules extends TaxRulesEvent {
  final String token;
  const LoadTaxRules({required this.token});
  @override
  List<Object?> get props => [token];
}

class CreateTaxRuleEvent extends TaxRulesEvent {
  final Map<String, dynamic> body;
  final String token;
  const CreateTaxRuleEvent({required this.body, required this.token});
  @override
  List<Object?> get props => [body, token];
}

class UpdateTaxRuleEvent extends TaxRulesEvent {
  final int id;
  final Map<String, dynamic> body;
  final String token;
  const UpdateTaxRuleEvent({required this.id, required this.body, required this.token});
  @override
  List<Object?> get props => [id, body, token];
}

class DeleteTaxRuleEvent extends TaxRulesEvent {
  final int id;
  final String token;
  const DeleteTaxRuleEvent({required this.id, required this.token});
  @override
  List<Object?> get props => [id, token];
}

class LocalReplaceRules extends TaxRulesEvent {
  final List<TaxRule> rules;
  const LocalReplaceRules(this.rules);
  @override
  List<Object?> get props => [rules];
}
