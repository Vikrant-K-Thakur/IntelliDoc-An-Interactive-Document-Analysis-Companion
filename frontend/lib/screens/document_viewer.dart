import 'package:flutter/material.dart';
import 'package:docuverse/shared/models/file_model.dart';
import 'package:pdfx/pdfx.dart';
import 'dart:io';

class DocumentViewerScreen extends StatefulWidget {
  final FileModel file;

  const DocumentViewerScreen({super.key, required this.file});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  PdfController? _pdfController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> _loadDocument() async {
    try {
      if (widget.file.type.toLowerCase() == 'pdf') {
        if (widget.file.path.isNotEmpty && File(widget.file.path).existsSync()) {
          _pdfController = PdfController(
            document: PdfDocument.openFile(widget.file.path),
          );
        } else {
          setState(() {
            _error = 'PDF file not found';
            _isLoading = false;
          });
          return;
        }
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading document: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Widget _buildPdfViewer() {
    if (_pdfController == null) {
      return const Center(
        child: Text('Unable to load PDF'),
      );
    }

    return PdfView(
      controller: _pdfController!,
      scrollDirection: Axis.vertical,
      onDocumentLoaded: (document) {
        // Document loaded successfully
      },
      onPageChanged: (page) {
        // Page changed
      },
    );
  }

  Widget _buildUnsupportedFormat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            widget.file.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'File Type: ${widget.file.extension}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Size: ${widget.file.formattedSize}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Preview not available for this file type',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement external app opening
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('External app opening coming soon'),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open with External App'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    if (widget.file.path.isEmpty || !File(widget.file.path).existsSync()) {
      return const Center(
        child: Text('Image file not found'),
      );
    }

    return InteractiveViewer(
      panEnabled: true,
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.file(
          File(widget.file.path),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text('Error loading image'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDocumentContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadDocument();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final fileType = widget.file.type.toLowerCase();
    
    if (fileType == 'pdf') {
      return _buildPdfViewer();
    } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(fileType)) {
      return _buildImageViewer();
    } else {
      return _buildUnsupportedFormat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.file.name,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share feature coming soon'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('More options coming soon'),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildDocumentContent(),
    );
  }
}