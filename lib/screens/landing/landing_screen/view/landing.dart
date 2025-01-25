import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../../app/components/other_widgets/web_view.dart';
import '../../../../app/constants/app/http_url.dart';
import '../controller/landing_controller.dart';

class Landing extends StatelessWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LandingController>();
    return MyWebView(
      showAppBar: false,
      url: HttpUrl.baseUrl,
    );
  }
}
