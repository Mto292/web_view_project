import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base_project/app/components/message/question_message_dialog.dart';
import 'package:flutter_base_project/app/components/message/toast_message.dart';
import 'package:flutter_base_project/app/extensions/widget_extension.dart';
import 'package:flutter_base_project/app/navigation/route/route.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:overlay_kit/overlay_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/response/web_view_request_model.dart';

class MyInWebView extends StatefulWidget {
  final String? url;
  final String? contentBase64;
  final String? contentHtml;
  final bool showAppBar;
  final Color? progressColor;
  final Color? progressBackgroundColor;
  final Function(String)? listenToUrl;

  const MyInWebView({
    super.key,
    this.url,
    this.contentBase64,
    this.contentHtml,
    this.showAppBar = true,
    this.progressColor,
    this.progressBackgroundColor,
    this.listenToUrl,
  }) : assert(url != null || contentBase64 != null || contentHtml != null);

  @override
  State<MyInWebView> createState() => _MyInWebViewState();
}

class _MyInWebViewState extends State<MyInWebView> {
  late InAppWebViewController _controller;
  double _progress = 0;
  bool isLoadingFile = false;
  final fetchJs = """
(function() {
  // fetch override
  const oldFetch = window.fetch;
  window.fetch = function() {
    const [input, options] = arguments;
    const url = typeof input === 'string' ? input : input.url;
    const absoluteUrl = url.startsWith('http') ? url : window.location.origin + url;
    const method = options?.method || 'GET';
    const body = options?.body || '';
    const headers = options?.headers || {};

    window.flutter_inappwebview.callHandler('logRequest', {
      type: 'fetch',
      url: absoluteUrl,
      method: method,
      body: body,
      headers: headers
    });

    return oldFetch.apply(this, arguments);
  };

  // XMLHttpRequest override
  const oldXHROpen = XMLHttpRequest.prototype.open;
  XMLHttpRequest.prototype.open = function(method, url) {
    this._method = method;
    this._originalUrl = url;
    this._absoluteUrl = url.startsWith('http') ? url : window.location.origin + url;
    this._headers = {};
    return oldXHROpen.apply(this, arguments);
  };

  const oldXHRSetRequestHeader = XMLHttpRequest.prototype.setRequestHeader;
  XMLHttpRequest.prototype.setRequestHeader = function(header, value) {
    this._headers = this._headers || {};
    this._headers[header] = value;
    return oldXHRSetRequestHeader.apply(this, arguments);
  };

  const oldXHRSend = XMLHttpRequest.prototype.send;
  XMLHttpRequest.prototype.send = function(body) {
    window.flutter_inappwebview.callHandler('logRequest', {
      type: 'xhr',
      url: this._absoluteUrl,
      method: this._method,
      body: body,
      headers: this._headers || {}
    });
    return oldXHRSend.apply(this, arguments);
  };
})();
  """;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(title: const Text("Web View")) : AppBar(toolbarHeight: 0),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(context, MainScreensEnum.init.path, (route) => false);
        },
        child: Icon(
          CupertinoIcons.refresh,
          size: 20,
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: widget.url != null ? URLRequest(url: WebUri(widget.url!)) : null,
            initialData: widget.contentHtml != null
                ? InAppWebViewInitialData(data: widget.contentHtml!)
                : widget.contentBase64 != null
                    ? InAppWebViewInitialData(data: utf8.decode(base64.decode(widget.contentBase64!)))
                    : null,
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
                useOnDownloadStart: true,
              ),
            ),
            onWebViewCreated: (controller) {
              _controller = controller;
              controller.addJavaScriptHandler(
                handlerName: 'logRequest',
                callback: (args) {
                  debugPrint("JS'den gelen istek: $args");

                  try {
                    final String url = (args.first['url'] as String);

                    if (url.contains('/downloadMedia/') == false &&
                        (args.first['url'] as String).contains('/downloadDocuments') == false) {
                      return;
                    }
                    if (isLoadingFile == true) return;
                    isLoadingFile = true;
                    final model = WebViewRequestModel.fromJson(args.first);
                    _startDownload(
                      httpMethod: model.method,
                      url: model.url,
                      headers: model.headers,
                      body: model.body,
                    ).then((_) => isLoadingFile = false);
                  } catch (e) {
                    isLoadingFile = false;
                  }
                },
              );
            },
            onLoadStop: (controller, url) async {
              await controller.evaluateJavascript(source: fetchJs);
            },
            onProgressChanged: (controller, progress) {
              final e = progress;
              setState(() {
                _progress = progress / 100;
              });
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url.toString();

              if (widget.listenToUrl != null) widget.listenToUrl!(url);

              if (url.startsWith('tel:') || url.startsWith('mailto:')) {
                await launchUrl(Uri.parse(url));
                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.ALLOW;
            },
            onDownloadStartRequest: (controller, request) async {
              if (request.url.scheme == 'blob') return;
              _startDownload(url: request.url.toString(), httpMethod: 'GET');
            },
          ),
          if (_progress < 1)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: widget.progressBackgroundColor ?? Theme.of(context).colorScheme.primary,
              valueColor:
                  AlwaysStoppedAnimation<Color?>(widget.progressColor ?? Theme.of(context).colorScheme.secondary),
            ),
        ],
      ),
    );
  }

  Future<void> _startDownload({
    required String url,
    required String httpMethod,
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final didYouWantDownload = await QuestionMessageDialog(
        text: 'Dosyayı indirmek ister misiniz?',
      ).openSimpleDialog();
      if (didYouWantDownload == false) return;

      http.Response response;
      switch (httpMethod) {
        case 'GET':
          response = await http.get(Uri.parse(url), headers: headers).callWithProgress();
        case 'POST':
          response = await http.post(Uri.parse(url), headers: headers, body: body).callWithProgress();
        case 'PUT':
          response = await http.put(Uri.parse(url), headers: headers, body: body).callWithProgress();
        default:
          response = await http.get(Uri.parse(url), headers: headers).callWithProgress();
      }
      if (response.statusCode != 200) {
        showErrorToastMessage('Yükleme hatası, hata kodu: ${response.statusCode}');
        return;
      }

      final fileName = _getFileName(response.headers['content-disposition'] ?? '') ?? 'dosya.pdf';
      final Directory downloadsDirectory = await getExternalStorageDirectory().callWithProgress();
      final savePath = '${downloadsDirectory.path}/$fileName';

      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes).callWithProgress();

      final result = await QuestionMessageDialog(
        text: 'Dosya başarılı bi şekilde indirildi, açmak ister misiniz?',
      ).openSimpleDialog();
      if (result == true) await OpenFile.open(savePath);
    } catch (e) {
      showErrorToastMessage('Dosya indirme başarısız');
    }
  }

  String? _getFileName(String input) {
    try {
      final regex = RegExp(r'filename="([^"]+)"');
      final match = regex.firstMatch(input);
      if (match != null) {
        return match.group(1);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
