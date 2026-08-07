import 'dart:io';

import 'package:eClassify/data/cubits/subscription/fetch_payment_receipt_cubit.dart';
import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/log.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html_to_pdf_plus/flutter_html_to_pdf_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TransactionReceiptScreen extends StatefulWidget {
  const TransactionReceiptScreen({
    required this.transactionId,
    required this.transactionOrderId,
    super.key,
  });

  final int transactionId;
  final String transactionOrderId;

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments;
    if (arguments is! Map) {
      return MaterialPageRoute(builder: (_) => const Scaffold());
    }
    final transactionId = arguments['transactionId'];
    final orderId = arguments['transactionOrderId'];
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => FetchPaymentReceiptCubit(),
        child: TransactionReceiptScreen(
          transactionId: transactionId is int
              ? transactionId
              : int.tryParse('$transactionId') ?? 0,
          transactionOrderId: orderId?.toString() ?? '',
        ),
      ),
    );
  }

  @override
  State<TransactionReceiptScreen> createState() =>
      _TransactionReceiptScreenState();
}

class _TransactionReceiptScreenState extends State<TransactionReceiptScreen> {
  late final WebViewController _controller;
  String _htmlContent = '';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xffffffff))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (_) => NavigationDecision.prevent,
        ),
      );
    context.read<FetchPaymentReceiptCubit>().fetch(
          transactionId: widget.transactionId,
        );
  }

  Future<void> _downloadPdf() async {
    try {
      final targetFileName = 'Receipt_${widget.transactionOrderId}.pdf';
      final directory = await getTemporaryDirectory();

      final generatedPdfFile =
          await FlutterHtmlToPdf.convertFromHtmlContent(
        content: _htmlContent,
        configuration: PrintPdfConfiguration(
          targetDirectory: directory.path,
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
        HelperUtils.showSnackBarMessage(
          context,
          'errorDownloadingReceipt'.translate(context),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FetchPaymentReceiptCubit, FetchPaymentReceiptState>(
      listener: (context, state) {
        if (state is FetchPaymentReceiptSuccess) {
          _htmlContent = state.receiptHtml;
          _controller.loadHtmlString(_htmlContent);
        }
      },
      child: BlocBuilder<FetchPaymentReceiptCubit, FetchPaymentReceiptState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: context.color.backgroundColor,
            appBar: UiUtils.buildAppBar(
              context,
              showBackButton: true,
              title: 'paymentReceipt'.translate(context),
              actions: [
                if (state is FetchPaymentReceiptSuccess)
                  IconButton(
                    icon: const Icon(Icons.download_outlined),
                    onPressed: _downloadPdf,
                  ),
              ],
            ),
            body: SafeArea(
              child: switch (state) {
                FetchPaymentReceiptSuccess() =>
                  WebViewWidget(controller: _controller),
                FetchPaymentReceiptFailure() => const SomethingWentWrong(),
                _ => Center(child: UiUtils.progress()),
              },
            ),
          );
        },
      ),
    );
  }
}
