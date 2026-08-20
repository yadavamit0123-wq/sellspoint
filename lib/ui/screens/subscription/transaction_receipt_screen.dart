import 'dart:io';

import 'package:eClassify/data/cubits/subscription/fetch_receipt_cubit.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/log.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html_to_pdf_plus/flutter_html_to_pdf_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:eClassify/utils/app_icons.dart';

class TransactionReceiptScreen extends StatefulWidget {
  const TransactionReceiptScreen({
    required this.transactionId,
    required this.transactionOrderId,
    super.key,
  });

  final int transactionId;
  final String transactionOrderId;

  @override
  State<TransactionReceiptScreen> createState() =>
      _TransactionReceiptScreenState();

  static Route route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => FetchReceiptCubit(),
        child: TransactionReceiptScreen(
          transactionId: arguments['transactionId'],
          transactionOrderId: arguments['transactionOrderId'],
        ),
      ),
    );
  }
}

class _TransactionReceiptScreenState extends State<TransactionReceiptScreen> {
  late final WebViewController _controller;
  String _htmlContent = "";

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xffffffff))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (_) {
            return NavigationDecision.prevent;
          },
        ),
      );
    context.read<FetchReceiptCubit>().fetchReceipt(widget.transactionId);
  }

  Future<void> _downloadPdf() async {
    try {
      final String targetFileName = "Receipt_${widget.transactionOrderId}.pdf";

      final File generatedPdfFile =
          await FlutterHtmlToPdf.convertFromHtmlContent(
            content: _htmlContent,
            configuration: PrintPdfConfiguration(
              targetDirectory: Constant.savePath,
              targetName: targetFileName,
            ),
          );

      await FilePicker.saveFile(
        fileName: targetFileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: generatedPdfFile.readAsBytesSync(),
      );
    } catch (e, stack) {
      Log.error(e.toString(), e, stack);
      if (mounted) {
        HelperUtils.showSnackBarMessage(context, 'errorDownloadingReceipt');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FetchReceiptCubit, FetchReceiptState>(
      listener: (context, state) {
        if (state is FetchReceiptSuccess) {
          _htmlContent = state.htmlContent;
          _controller.loadHtmlString(_htmlContent);
        }
      },
      child: BlocBuilder<FetchReceiptCubit, FetchReceiptState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text("paymentReceipt".translate(context)),
              actions: [
                if (state is FetchReceiptSuccess)
                  IconButton(
                    icon: const Icon(AppIcons.downloadSimple),
                    onPressed: _downloadPdf,
                  ),
              ],
            ),
            body: SafeArea(
              child: switch (state) {
                FetchReceiptSuccess() => WebViewWidget(controller: _controller),
                FetchReceiptFailure() => QErrorWidget(error: state.error),
                _ => Center(child: UiUtils.progress()),
              },
            ),
          );
        },
      ),
    );
  }
}
