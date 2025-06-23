import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/landing_controller.dart';
import 'view/landing.dart';

/// Hızlı giriş yap ekranı
/// Kullanıcı üye değil ise splashtan sonra ilk açılan ekran
/// 'landing page'
class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      tag: UniqueKey().hashCode.toString(),
      init: LandingController(),
      builder: (LandingController controller) {
        return Landing(controller: controller);
      },
    );
  }
}
