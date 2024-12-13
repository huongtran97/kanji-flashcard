import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:japanese_flashcard_application/model/reading_model.dart';
import 'package:provider/provider.dart';
import 'package:japanese_flashcard_application/my_app_state.dart';
import 'package:japanese_flashcard_application/model/favorite_model.dart' as favorite_model;
import 'package:japanese_flashcard_application/model/kanji_model.dart';  


class RandomWordPage extends StatefulWidget {
  @override
  RandomWordPageState createState() => RandomWordPageState();
}

class RandomWordPageState extends State<RandomWordPage> {
  final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  List<Map<String, dynamic>> wordHistory = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRandomWord(); // Load a random word when the page is initialized
  }

  Future<void> _loadRandomWord() async {
    var appState = context.read<MyAppState>();

    // Fetch a random kanji word from the app state
    await appState.getRandomWord(context); // Assuming appState provides kanji data

    if (appState.kanji.readings.isNotEmpty) {
      setState(() {
        Kanji currentKanji = appState.kanji;
        wordHistory.add({
          'characters': currentKanji.characters,
          'readings': currentKanji.readings, // List of ReadingModel
          'meanings': currentKanji.wordMeanings, // List of WordMeaning
        });
        currentIndex = wordHistory.length - 1; // Set the current index to the latest word
      });
    } else {
      Fluttertoast.showToast(
        msg: "Failed to load a new word!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  void _showPreviousWord() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  void _toggleFavorite() {
    var appState = context.read<MyAppState>();
    var currentWord = wordHistory[currentIndex];
    var character = currentWord['characters'] as String;
    var readings = currentWord['readings']; // List of ReadingModel

    print("Readings: $readings"); // Debugging the readings

    // Separate readings into categories based on type (onyomi, kunyomi, etc.)
    var onyomiReadings = readings
        .where((reading) => reading.type == 'onyomi')
        .map((reading) => reading.reading)
        .toList()
        .cast<String>();

    var kunyomiReadings = readings
        .where((reading) => reading.type == 'kunyomi')
        .map((reading) => reading.reading)
        .toList()
        .cast<String>();

    var nanoriReadings = readings
        .where((reading) => reading.type == 'nanori')
        .map((reading) => reading.reading)
        .toList()
        .cast<String>();

    // Create a FavoriteModel instance
    var favorite = favorite_model.FavoriteModel(
      word: character,
      onyomiReadings: onyomiReadings,
      kunyomiReadings: kunyomiReadings,
      nanoriReadings: nanoriReadings,
    );

    // Toggle the favorite in app state
    appState.toggleFavorite(favorite);

    setState(() {});
  }

  // Method to convert kanji or readings to romaji
 

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (wordHistory.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    var currentWord = wordHistory[currentIndex];
    var word = currentWord['characters'] as String;
    var readings = currentWord['readings'] as List<ReadingModel>;

    // Separate readings by type
    var onyomiReadings = readings
        .where((reading) => reading.type == 'onyomi')
        .map((reading) => reading.reading)
        .toList()
        .cast<String>();

    var kunyomiReadings = readings
        .where((reading) => reading.type == 'kunyomi')
        .map((reading) => reading.reading)
        .toList()
        .cast<String>();

    var nanoriReadings = readings
        .where((reading) => reading.type == 'nanori')
        .map((reading) => reading.reading)
        .toList()
        .cast<String>();

    bool isFavorite = appState.favorites.any(
      (favorite) =>
          favorite.word == word &&
          listEquals(favorite.onyomiReadings, onyomiReadings) &&
          listEquals(favorite.kunyomiReadings, kunyomiReadings) &&
          listEquals(favorite.nanoriReadings, nanoriReadings),
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => cardKey.currentState?.toggleCard(),
            child: SizedBox(
              width: 300,
              height: 400,
              child: FlipCard(
                key: cardKey,
                front: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      word,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 75,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                  ),
                ),
                back: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (onyomiReadings.isNotEmpty)
                          Text(
                            'Onyomi: ${onyomiReadings.join(', ')}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: 18, color: Colors.blueAccent),
                          )
                        else
                          Text('No Onyomi available'),
                        if (kunyomiReadings.isNotEmpty)
                          Text(
                            'Kunyomi: ${kunyomiReadings.join(', ')}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: 18, color: Colors.blueAccent),
                          )
                        else
                          Text('No Kunyomi available'),
                        if (nanoriReadings.isNotEmpty)
                          Text(
                            'Nanori: ${nanoriReadings.join(', ')}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: 18, color: Colors.blueAccent),
                          )
                        else
                          Text('No Nanori available'),
                        
                        SizedBox(height: 10),
                        
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: currentIndex > 0 ? _showPreviousWord : null,
                icon: Icon(Icons.arrow_back),
                label: Text('Previous'),
              ),
              SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _toggleFavorite,
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _loadRandomWord,
                icon: Icon(Icons.arrow_forward),
                label: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
