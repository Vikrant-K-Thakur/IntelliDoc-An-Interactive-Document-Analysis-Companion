import 'package:flutter/material.dart';
import 'package:docuverse/widgets/voice_button.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final String content;
  final String? languageCode;
  final VoidCallback? onListen;

  const ResultCard({
    super.key,
    required this.title,
    required this.content,
    this.languageCode,
    this.onListen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (onListen != null && languageCode != null)
                  VoiceButton(
                    languageCode: languageCode!,
                    onPressed: onListen!,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}