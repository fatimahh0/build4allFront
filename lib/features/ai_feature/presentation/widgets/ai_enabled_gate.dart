import 'package:flutter/material.dart';
import 'package:build4front/core/network/globals.dart' as net;
import 'package:build4front/features/ai_feature/ai_feature_bootstrap.dart';

/// ✅ Fixes "sometimes" AI button by refreshing status once when the widget mounts.
class AiEnabledGate extends StatefulWidget {
  const AiEnabledGate({
    super.key,
    required this.whenEnabled,
    this.whenDisabled,
    this.refreshOnMount = true,
    this.minRefreshInterval = const Duration(seconds: 15),
  });

  final WidgetBuilder whenEnabled;
  final Widget? whenDisabled;
  final bool refreshOnMount;
  final Duration minRefreshInterval;

  @override
  State<AiEnabledGate> createState() => _AiEnabledGateState();
}

class _AiEnabledGateState extends State<AiEnabledGate> {
  bool _refreshed = false;

  @override
  void initState() {
    super.initState();

    if (widget.refreshOnMount) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted || _refreshed) return;
        _refreshed = true;
        await AiFeatureBootstrap().refresh(minInterval: widget.minRefreshInterval);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: net.aiEnabledNotifier,
      builder: (_, enabled, __) {
        if (!enabled) return widget.whenDisabled ?? const SizedBox.shrink();
        return widget.whenEnabled(context);
      },
    );
  }
}