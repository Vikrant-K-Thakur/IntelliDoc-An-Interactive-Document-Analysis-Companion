import 'package:flutter/material.dart';
import 'package:docuverse/models/flashcard_model.dart';

class FlashcardsPage extends StatefulWidget {
  const FlashcardsPage({super.key});

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  late List<Flashcard> _flashcards;
  int _currentIndex = 0;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _flashcards = ModalRoute.of(context)!.settings.arguments as List<Flashcard>;
  }

  void _nextCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _flashcards.length;
      _showAnswer = false;
    });
  }

  void _prevCard() {
    setState(() {
      _currentIndex = (_currentIndex - 1) % _flashcards.length;
      _showAnswer = false;
    });
  }

  void _toggleAnswer() {
    setState(() => _showAnswer = !_showAnswer);
  }

  @override
  Widget build(BuildContext context) {
    final flashcard = _flashcards[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _toggleAnswer,
              child: Card(
                margin: const EdgeInsets.all(20),
                child: Container(
                  width: 300,
                  height: 200,
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      _showAnswer ? flashcard.backText : flashcard.frontText,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${_currentIndex + 1}/${_flashcards.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _prevCard,
                  iconSize: 40,
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _toggleAnswer,
                  child: Text(_showAnswer ? 'Show Question' : 'Show Answer'),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextCard,
                  iconSize: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}