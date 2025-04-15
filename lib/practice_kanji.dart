import 'package:flutter/material.dart';
import 'package:japanese_flashcard_application/model/reading_model.dart';
import 'package:provider/provider.dart';
import 'model/kanji_model.dart';
import 'my_app_state.dart';
import 'package:kana_kit/kana_kit.dart';

class PracticeKanjiPage extends StatefulWidget {
  @override
  PracticeKanjiPageState createState() => PracticeKanjiPageState();
}

class PracticeKanjiPageState extends State<PracticeKanjiPage> {
  Kanji? _currentKanji;
  TextEditingController _controller = TextEditingController();
  Widget _feedbackWidget = SizedBox(); 
  final kanaKit = KanaKit();

  @override
  void initState() {
    super.initState();
    _loadRandomWord();
  }

  Future<void> _loadRandomWord() async {
    var appState = context.read<MyAppState>();
    await appState.getRandomWord(context);
    if (appState.kanji.readings.isNotEmpty) {
      if (mounted) {
      setState(() {
        _currentKanji = appState.kanji;
        _feedbackWidget = SizedBox(); 
      });
      }
    }
  }

  ReadingModel? isCorrectInput(
      String userInputRomaji, List<ReadingModel> readings) {
    String convertedRomaji = userInputRomaji.trim().toLowerCase();

    for (var reading in readings) {
      String readingRomaji = kanaKit.toRomaji(reading.reading);
      if (readingRomaji.toLowerCase() == convertedRomaji) {
        return reading;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_currentKanji != null) ...[
            Text(
              _currentKanji!.characters,
              style: TextStyle(fontSize: 78, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
          ] else ...[
            CircularProgressIndicator(),
          ],
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your answer here',
              ),
            ),
          ),
          SizedBox(height: 10),
          _feedbackWidget, // Display feedback widget
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_currentKanji == null) return;

                  String userInputRomaji = _controller.text.trim();
                  var correctReading =
                      isCorrectInput(userInputRomaji, _currentKanji!.readings);

                  setState(() {
                    if (correctReading != null) {
                      _feedbackWidget = Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, color: Colors.green),
                              Text(
                                "Correct!",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green),
                              ),
                              SizedBox(width: 8),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text("Reading: ${correctReading.reading}", 
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),),
                          Text(
                              "Meaning: ${_currentKanji?.meanings.first.meaning ?? 'No meaning available'}",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                          ),),
                        ],
                      );
                    } else {
                      // Get all possible correct readings
                      List<String> correctReadings = _currentKanji!.readings
                          .map((reading) => kanaKit.toRomaji(reading.reading))
                          .toList();
                      String correctReadingsText = correctReadings.join(", ");

                      _feedbackWidget = Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.close, color: Colors.red),
                              Text(
                                "Incorrect!",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                              SizedBox(width: 8),                            
                            ],
                          ),
                          SizedBox(height: 5),
                          Text("Correct answer: $correctReadingsText",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),),
                        ],
                      );
                    }
                  });
                },
                child: Text('Check'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  _controller.clear();
                  _loadRandomWord();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
