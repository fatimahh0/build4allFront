import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4front/l10n/app_localizations.dart';

import 'package:build4front/features/profile/presentation/bloc/user_profile_bloc.dart';

class DeactivateUserDialog extends StatefulWidget {
  final String token;
  final int userId;
  final int ownerProjectLinkId;

  const DeactivateUserDialog({
    super.key,
    required this.token,
    required this.userId,
    required this.ownerProjectLinkId,
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

  String _extractErrorMessage(dynamic error, AppLocalizations tr) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        final backendError = data['error'];
        final backendMessage = data['message'];

        if (backendError is String && backendError.trim().isNotEmpty) {
          return backendError.trim();
        }

        if (backendMessage is String && backendMessage.trim().isNotEmpty) {
          return backendMessage.trim();
        }
      }

      if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }

      return tr.profile_load_error;
    }

    if (error is String && error.trim().isNotEmpty) {
      return error.trim();
    }

    return tr.profile_load_error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tr = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(tr.deactivate_title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr.deactivate_warning),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              obscureText: true,
              enabled: !_busy,
              decoration: InputDecoration(
                labelText: tr.current_password_label,
                hintText: tr.current_password_label,
                filled: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_error != null) {
                  setState(() => _error = null);
                }
              },
              onSubmitted: (_) => _submit(context),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.error.withOpacity(0.35),
                  ),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            if (_busy) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(minHeight: 2),
            ],
          ],
        ),
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
      final bloc = context.read<UserProfileBloc>();

      await bloc.updateStatusDirect(
        token: widget.token,
        userId: widget.userId,
        status: 'INACTIVE',
        password: pwd,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = _extractErrorMessage(e, tr);
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}