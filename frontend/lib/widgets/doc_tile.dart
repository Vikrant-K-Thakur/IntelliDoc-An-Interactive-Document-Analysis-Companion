import 'package:flutter/material.dart';
import 'package:docuverse/models/document_model.dart';
import 'package:docuverse/utils/helpers.dart';

class DocTile extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const DocTile({
    super.key,
    required this.document,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            document.type == 'PDF'
                ? Icons.picture_as_pdf
                : document.type == 'Word'
                    ? Icons.description
                    : document.type == 'PowerPoint'
                        ? Icons.slideshow
                        : Icons.image,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          document.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        subtitle: Text(
          'Uploaded on ${Helpers.formatDate(DateTime.parse(document.uploadDate))}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}