import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:japanese_flashcard_application/model/kanji_model.dart';
import 'package:japanese_flashcard_application/model/meaning_model.dart';
import 'package:japanese_flashcard_application/model/reading_model.dart';
import 'model/favorite_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'hiragana_to_romaji_map.dart';

class MyAppState extends ChangeNotifier {
  String word = '';
  List<String> readings = [];
  List<String> meanings =[]; 
  String romaji = '';
  var favorites = <FavoriteModel>[];
  String wordId = '';
  late Kanji kanji;

  static const String apiToken = '855ce78d-8e82-4056-8794-cb5676fb33ca';

  final Set<String> usedIds = {};

  // Fetch random word from the API
  Future<void> getRandomWord(BuildContext context) async {

    
    final url = Uri.parse(
      'https://api.wanikani.com/v2/subjects?types=kanji&levels=1,2,3,4,5',
    );
    final List allItems = [];

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $apiToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Check if 'data' is a list
      if (data['data'] is List) {
        final List<dynamic> items = data['data'] as List<dynamic>;
        allItems.addAll(items);
      } else {
        print('Expected a list but got: ${data['data']}');
        return;
      }
    } else {
      print('Failed to load vocabulary: ${response.statusCode}');
      return;
    }

    // Filter out used words
    final newItems = allItems.where((item) {
      final wordId = item['id'].toString();
      return !usedIds.contains(wordId);
    }).toList();

    if (newItems.isEmpty) {
      if (!context.mounted) return;

      Fluttertoast.showToast(
        msg: "All words have been used!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('No more new word!'),
          content: Text('Would you like to regenerate?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                usedIds.clear();
                Navigator.pop(context);
                getRandomWord(context);
              },
              child: Text('Yes'),
            ),
          ],
        ),
      );
      return;
    }

    final random = Random();
    final randomIndex = random.nextInt(newItems.length);
    final randomItem = newItems[randomIndex];

    word = randomItem['data']['characters'];

    // Ensure readings is a List<ReadingModel>
    final List<ReadingModel> readingsList = (randomItem['data']['readings'] as List<dynamic>?)
        ?.map((item) => ReadingModel.fromJson(item))
        .toList() ?? [];

    final List<WordMeaningModel> meaningsList = (randomItem['data']['meanings'] as List<dynamic>?)
        ?.map((item) => WordMeaningModel.fromJson(item))
        .toList() ?? [];

    // Update the readings list
    readings = readingsList.map((reading) => reading.reading).toList();

    // Convert readings to romaji
    romaji = convertToRomaji(readingsList.map((reading) => reading.reading).toList());

    // Set word ID
    wordId = randomItem['id'].toString();

    usedIds.add(wordId);

    // Set the 'kanji' object
    kanji = Kanji(
      level: randomItem['data']['level'],
      characters: word,
      wordMeanings: meaningsList,
      readings: readingsList,
    );

    // Notify listeners to update the UI
    notifyListeners();
  }

  // Convert Hiragana readings to Romaji
  String convertToRomaji(List<String> readings) {
    return readings
        .map((reading) => reading.split('').map((char) => hiraganaToRomajiMap[char] ?? char))
        .join(', ');  // Join individual readings with a comma
  }

  // Toggle favorite
  void toggleFavorite(FavoriteModel favorite) {
    final index = favorites.indexWhere((f) => f.word == favorite.word);
    if (index == -1) {
      favorites.add(favorite); // Add to favorites
    } else {
      favorites.removeAt(index); // Remove from favorites
    }
    notifyListeners(); // Notify listeners to update the UI
  }
}
