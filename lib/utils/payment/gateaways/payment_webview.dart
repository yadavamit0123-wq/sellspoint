import 'dart:developer';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:eClassify/utils/app_icons.dart';

class PaymentWebView extends StatefulWidget {
  final String authorizationUrl;
  final String? reference;
  final Function(String) onSuccess;
  final Function(String) onFailed;
  final Function() onCancel;

  const PaymentWebView({
    Key? key,
    required this.authorizationUrl,
    this.reference,
    required this.onSuccess,
    required this.onFailed,
    required this.onCancel,
  }) : super(key: key);

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onUrlChange: (UrlChange change) {
            final url = change.url ?? '';
            log('$url');
            if (url.contains("Completed") ||
                url.contains("completed") ||
                url.toLowerCase().contains("success")) {
              widget.onSuccess(widget.reference ?? '');
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.activePlanScreen,
                (route) => route.isFirst,
              );
            } else if (url.contains("Failed") ||
                url.contains("failed") ||
                url.contains("cancel")) {
              widget.onFailed(widget.reference ?? '');

              Navigator.of(context).popUntil(
                (route) =>
                    route.settings.name == Routes.subscriptionPackageScreen ||
                    route.isFirst,
              );
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = request.url;
            log('${uri.toString()}', name: 'NAVIGATION');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText('payment'.translate(context)),
        leading: IconButton(
          icon: const Icon(AppIcons.x),
          onPressed: () {
            widget.onCancel();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}
