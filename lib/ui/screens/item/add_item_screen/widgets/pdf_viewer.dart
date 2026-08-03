import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class PdfViewer extends StatefulWidget {
  final String url;

  const PdfViewer({Key? key, required this.url}) : super(key: key);

  @override
  _PDFViewerState createState() => _PDFViewerState();

  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => PdfViewer(
        url: arguments?['url'],
        // from: arguments?['from'],
      ),
    );
  }
}

class _PDFViewerState extends State<PdfViewer> {
  late File Pfile;
  bool isLoading = false;
  PdfControllerPinch? _pdfController;
  Future<void> loadNetwork() async {
    setState(() {
      isLoading = true;
    });
    var url = widget.url;

    try {
      Response response = await Dio()
          .get(url, options: Options(responseType: ResponseType.bytes));
      final bytes = response.data;
      final filename =
          path.basename(url); // Use path.basename instead of basename
      final dir = await getApplicationDocumentsDirectory();
      var file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes, flush: true);

      _pdfController = PdfControllerPinch(
        document: PdfDocument.openFile(file.path),
      );
      setState(() {
        Pfile = file;
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    loadNetwork();

    super.initState();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: UiUtils.buildAppBar(
        context,
        backgroundColor: context.color.secondaryDetailsColor,
        showBackButton: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pdfController == null
          ? const Center(child: Text("PDF Not Found"))
          : PdfViewPinch(
        controller: _pdfController!,
        onDocumentError: (error) {
          print('PDF Error: $error');
        },
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) =>
          const Center(child: CircularProgressIndicator()),
          pageLoaderBuilder: (_) =>
          const Center(child: CircularProgressIndicator()),
          errorBuilder: (_, error) =>
              Center(child: Text(error.toString())),
        ),
      ),
    );
  }
}
