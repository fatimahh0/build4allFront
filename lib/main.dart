import 'package:flutter/material.dart';

import 'package:build4front/app/app.dart';
import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/network/globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global Dio + globals (ownerProjectLinkId, etc.)
  makeDefaultDio(Env.apiBaseUrl);

  runApp(const Build4AllFrontApp());
}
