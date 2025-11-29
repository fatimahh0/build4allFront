// lib/core/network/connecting(wifiORserver)/connection_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'connection_cubit.dart';
import 'connection_status.dart';
import 'package:build4front/l10n/app_localizations.dart';

class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context)!;

    return BlocBuilder<ConnectionCubit, ConnectionStateModel>(
      builder: (context, state) {
        if (state.status == ConnectionStatus.online) {
          // Online → hide banner
          return const SizedBox.shrink();
        }

        Color bg;
        String text;

        switch (state.status) {
          case ConnectionStatus.offline:
            bg = Colors.redAccent;
            text = l.connection_offline; // "No internet connection"
            break;
          case ConnectionStatus.serverDown:
            bg = Colors.orange;
            text = state.message ?? l.connection_server_down;
            break;
          default:
            bg = c.error;
            text = l.connection_issue;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: bg,
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: t.bodyMedium?.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
