import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart' show BuildContext, FocusScope;

extension CheckInternetExtension on BuildContext {
  ///it written for check the internet
  Future<bool> checkInternet() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.first == ConnectivityResult.none) {
        return false;
      } else {
        return true;
      }
    } catch (_) {
      return true;
    }
  }

  void unFocus() => FocusScope.of(this).unfocus();
}
