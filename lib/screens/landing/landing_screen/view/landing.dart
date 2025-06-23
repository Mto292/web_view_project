import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../../app/components/other_widgets/in_app_web_view.dart';
import '../../../../app/constants/app/http_url.dart';
import '../controller/landing_controller.dart';

class Landing extends StatelessWidget {
  final LandingController controller;

  const Landing({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MyInWebView(
      showAppBar: false,
      url: HttpUrl.baseUrl,
    );
  }
}
