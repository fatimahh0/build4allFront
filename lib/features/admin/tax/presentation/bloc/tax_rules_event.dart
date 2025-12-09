import 'package:equatable/equatable.dart';
import '../../domain/entities/tax_rule.dart';

abstract class TaxRulesEvent extends Equatable {
  const TaxRulesEvent();
  @override
  List<Object?> get props => [];
}

class LoadTaxRules extends TaxRulesEvent {
  final int ownerProjectId;
  final String token;
  const LoadTaxRules({required this.ownerProjectId, required this.token});

  @override
  List<Object?> get props => [ownerProjectId, token];
}

class CreateTaxRuleEvent extends TaxRulesEvent {
  final Map<String, dynamic> body;
  final String token;
  final int ownerProjectId;
  const CreateTaxRuleEvent({
    required this.body,
    required this.token,
    required this.ownerProjectId,
  });

  @override
  List<Object?> get props => [body, token, ownerProjectId];
}

class UpdateTaxRuleEvent extends TaxRulesEvent {
  final int id;
  final Map<String, dynamic> body;
  final String token;
  final int ownerProjectId;

  const UpdateTaxRuleEvent({
    required this.id,
    required this.body,
    required this.token,
    required this.ownerProjectId,
  });

  @override
  List<Object?> get props => [id, body, token, ownerProjectId];
}

class DeleteTaxRuleEvent extends TaxRulesEvent {
  final int id;
  final String token;
  final int ownerProjectId;

  const DeleteTaxRuleEvent({
    required this.id,
    required this.token,
    required this.ownerProjectId,
  });

  @override
  List<Object?> get props => [id, token, ownerProjectId];
}

class LocalReplaceRules extends TaxRulesEvent {
  final List<TaxRule> rules;
  const LocalReplaceRules(this.rules);

  @override
  List<Object?> get props => [rules];
}
