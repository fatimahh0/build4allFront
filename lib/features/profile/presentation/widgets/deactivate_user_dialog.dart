import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/l10n/app_localizations.dart';
import 'package:build4front/features/profile/domain/usecases/update_user_status.dart';

class DeactivateUserDialog extends StatefulWidget {
  final String token;
  final int userId;

  const DeactivateUserDialog({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<DeactivateUserDialog> createState() => _DeactivateUserDialogState();
}

class _DeactivateUserDialogState extends State<DeactivateUserDialog> {
  final _ctrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tr = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(tr.deactivate_title), // add key
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tr.deactivate_warning), // add key
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: tr.current_password_label, // add key
              errorText: _error,
              filled: true,
            ),
            onSubmitted: (_) => _submit(context),
          ),
          if (_busy) const SizedBox(height: 8),
          if (_busy) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: Text(
            tr.cancel,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
        ElevatedButton(
          onPressed: _busy ? null : () => _submit(context),
          child: Text(tr.confirm),
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context) async {
    final tr = AppLocalizations.of(context)!;
    final pwd = _ctrl.text.trim();

    if (pwd.isEmpty) {
      setState(() => _error = tr.fieldRequired);
      return;
    }

    setState(() {
      _error = null;
      _busy = true;
    });

    try {
      final uc = context.read<UpdateUserStatus>();
      await uc(
        token: widget.token,
        userId: widget.userId,
        status: 'INACTIVE',
        password: pwd,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
