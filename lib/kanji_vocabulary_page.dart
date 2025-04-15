import 'package:flutter/material.dart';
import 'package:japanese_flashcard_application/model/reading_model.dart';
import 'package:japanese_flashcard_application/my_app_state.dart';
import 'package:japanese_flashcard_application/model/kanji_model.dart';
import 'package:provider/provider.dart';
import 'kanji_details_page.dart';

class KanjiVocabularyPage extends StatefulWidget {
  @override
  State<KanjiVocabularyPage> createState() => KanjiVocabularyPageState();
}

class KanjiVocabularyPageState extends State<KanjiVocabularyPage> {
  List<Kanji> kanjiList = [];
  List<ReadingModel> readingList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    var appState = context.read<MyAppState>();

    await appState.getAllWords(context);

    if (mounted) {
      setState(() {
      if (appState.kanjiList.isNotEmpty) {
        kanjiList = appState.kanjiList
            .where((kanji) => kanji.level >= 1 && kanji.level <= 80)
            .toList();

        readingList = kanjiList.expand((kanji) => kanji.readings).toList();
      }
      isLoading = false;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('Kanji - Level 1 to 20')),
      body: Container(
        color: colorScheme.primaryContainer,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 7.5,
                  mainAxisSpacing: 7.5,
                ),
                itemCount: kanjiList.length,
                itemBuilder: (context, index) {
                  final kanji = kanjiList[index];
                  final reading = kanji.readings;
                  
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              KanjiDetailPage(kanji: kanji, readings: reading),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4.0,
                      child: Stack(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                kanji.characters,
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 8.0,
                            top: 8.0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                '${kanji.level}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
