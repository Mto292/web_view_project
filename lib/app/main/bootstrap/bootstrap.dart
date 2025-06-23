import 'dart:async';
import 'package:dop_logger/dop_logger.dart';
import 'package:flutter/material.dart';
import '../../app.dart';

/// Tüm proje ortamları bu bootstrap Fon. nunu çağırmakta
Future<void> bootstrap(String lokiUrl, App app) async {
  await DopLogger.init(
    lokiUrl,
    false,
    false,
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      runApp.call(app);
    },
  );
}
