import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../models/document_model.dart';

class DocumentViewer extends StatefulWidget {
  const DocumentViewer({super.key});

  @override
  State<DocumentViewer> createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  late PdfController _pdfController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    final document = ModalRoute.of(context)!.settings.arguments as Document;
    
    try {
      _pdfController = PdfController(
        document: PdfDocument.openFile(document.fileUrl!),
      );
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load document';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Viewer')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : PdfView(
                  controller: _pdfController,
                ),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }
}