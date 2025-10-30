import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:docuverse/models/document_model.dart';
import 'package:docuverse/models/flashcard_model.dart';
import 'package:docuverse/models/study_plan_model.dart';
import 'package:docuverse/services/api_service.dart';
import 'package:docuverse/services/tts_service.dart';
import 'package:docuverse/widgets/result_card.dart';
import 'package:docuverse/widgets/language_selector.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final TtsService _ttsService = TtsService();
  Document? _document;
  String _summary = '';
  List<Flashcard> _flashcards = [];
  StudyPlan? _studyPlan;
  bool _isLoading = true;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final document = ModalRoute.of(context)!.settings.arguments as Document;
    setState(() {
      _document = document;
      _isLoading = true;
    });

    try {
      final summary = await ApiService.summarizeDocument(document.id);
      final flashcards = await ApiService.generateFlashcards(document.id);
      final studyPlan = await ApiService.generateStudyPlan(document.id);

      if (mounted) {
        setState(() {
          _summary = summary;
          _flashcards = flashcards;
          _studyPlan = studyPlan;
          _isLoading = false;
        });
      }
    }  catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _listenToSummary() async {
    try {
      await _ttsService.speak(_summary, language: _selectedLanguage);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to play audio: ${e.toString()}')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_document?.title ?? 'Document Results'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.summarize)),
              Tab(icon: Icon(Icons.chat)),
              Tab(icon: Icon(Icons.flash_on)),
              Tab(icon: Icon(Icons.calendar_today)),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Summary Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        LanguageSelector(
                          selectedLanguage: _selectedLanguage,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedLanguage = value);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        ResultCard(
                          title: 'Summary',
                          content: _summary,
                          languageCode: _selectedLanguage,
                          onListen: _listenToSummary,
                        ),
                      ],
                    ),
                  ),
                  
                  // Chat Tab
                  const Center(child: Text('Chat with Document')),

                  // Flashcards Tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_flashcards.length} Flashcards Generated',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/flashcards',
                              arguments: _flashcards,
                            );
                          },
                          child: const Text('View Flashcards'),
                        ),
                      ],
                    ),
                  ),

                  // Study Plan Tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Study Plan Generated',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/study-plan',
                              arguments: _studyPlan,
                            );
                          },
                          child: const Text('View Study Plan'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }
}