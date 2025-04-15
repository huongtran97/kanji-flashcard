import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:japanese_flashcard_application/model/audio_model.dart';
import 'package:japanese_flashcard_application/model/context_sentence_model.dart';
import 'package:japanese_flashcard_application/model/kanji_model.dart';
import 'package:japanese_flashcard_application/model/meaning_model.dart';
import 'package:japanese_flashcard_application/model/reading_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/favorite_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'hiragana_to_romaji_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyAppState extends ChangeNotifier {
  String word = '';
  String slug = '';
  List<String> readings = [];
  List<String> meanings = [];
  List<String> contextSentences = [];
  List<String> audios = [];
  String romaji = '';
  List<FavoriteModel> favorites = [];
  String wordId = '';
  List<Kanji> kanjiList = [];
  late Kanji kanji;
  List<Map<String, dynamic>> wordHistory = [];
  int currentIndex = 0;
  bool _isFavoritesLoaded = false;
  bool get isFavoritesLoaded => _isFavoritesLoaded;
  static final String apiToken = dotenv.env['API_TOKEN'] ?? '';
  static final String url = dotenv.env['URL'] ?? '';

  final Set<String> usedIds = {};

  // Fetch random word from the API
  Future<void> getRandomWord(BuildContext context) async {
    final List allItems = [];

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $apiToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if data is a list
        if (data['data'] is List) {
          final List<dynamic> items = data['data'] as List<dynamic>;
          allItems.addAll(items);
        } else {
          print('Expected a list but got: ${data['data']}');
          return;
        }
      } else {
        print('Failed to load vocabulary: ${response.statusCode}');
        throw Exception('Failed to load vocabulary');
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
            title: Text('No more new words!'),
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
                  getRandomWord(context); // Recursively fetch new words
                },
                child: Text('Yes'),
              ),
            ],
          ),
        );
        return;
      }

      // Select a random word from newItems
      final random = Random();
      final randomIndex = random.nextInt(newItems.length);
      final randomItem = newItems[randomIndex];

      word = randomItem['data']['characters'];
      final List<ReadingModel> readingsList =
          (randomItem['data']['readings'] as List<dynamic>?)
                  ?.map((item) => ReadingModel.fromJson(item))
                  .toList() ??
              [];

      final List<MeaningModel> meaningsList =
          (randomItem['data']['meanings'] as List<dynamic>?)
                  ?.map((item) => MeaningModel.fromJson(item))
                  .toList() ??
              [];

      final List<ContextSentence> sentenceList =
          (randomItem['data']['context_sentences'] as List<dynamic>?)
                  ?.map((item) => ContextSentence.fromJson(item))
                  .toList() ??
              [];

      final List<Audio> audiosList =
          (randomItem['data']['pronunciation_audios'] as List<dynamic>?)
                  ?.map((item) => Audio.fromJson(item))
                  .toList() ??
              [];

      // Update state
      readings = readingsList.map((reading) => reading.reading).toList();
      romaji = convertToRomaji(
          readingsList.map((reading) => reading.reading).toList());
      wordId = randomItem['id'].toString();
      usedIds.add(wordId);

      // Update Kanji model with new word
      kanji = Kanji(
        level: randomItem['data']['level'],
        characters: word,
        slug: slug,
        meanings: meaningsList,
        readings: readingsList,
        contextSentences: sentenceList,
        audios: audiosList,
      );

      notifyListeners();
    } catch (e) {
      print("Error fetching random word: $e");
    }
  }

  Future<void> getAllWords(BuildContext context) async {
    final response = await http
        .get(Uri.parse(url), headers: {'Authorization': 'Bearer $apiToken'});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Check if data is a list and contains Kanji
      if (data['data'] is List) {
        kanjiList =
            (data['data'] as List).map((item) => Kanji.fromJson(item)).toList();
        print("Kanji data fetched: ${kanjiList.length} items found.");
      } else {
        print("Unexpected data format: ${data['data']}");
      }
    } else {
      print("Failed to fetch Kanji. Status code: ${response.statusCode}");
    }
  }

  // Convert Hiragana readings to Romaji
  String convertToRomaji(List<String> readings) {
    return readings
        .map((reading) => reading
            .split('')
            .map((char) => hiraganaToRomajiMap[char] ?? char)
            .join())
        .join(', ');
  }

  // Add Kanji word into Favorite list with an UI update
  void toggleFavorite(FavoriteModel favorite) {
    if (!favorites.contains(favorite)) {
      favorites.add(favorite);
    } else {
      favorites.remove(favorite);
    }

    saveFavorites(favorites);

    notifyListeners();
  }

  bool isFavorite(FavoriteModel favorite) {
    return favorites.contains(favorite);
  }

  Future<String?> fetchPronunciationForCurrentWord(String character) async {
  final response = await http.get(
    Uri.parse(url),
    headers: {'Authorization': 'Bearer $apiToken'},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    for (var item in data['data']) {
      String apiCharacter = item['data']['characters'];
      if (apiCharacter == character) {
        var audios = item['data']['pronunciation_audios'];
        if (audios.isNotEmpty) {
          return audios[0]['url'];
        }
      }
    }
    return null; 
  } else {
    print("Failed to fetch data: ${response.statusCode}");
    return null;
  }
}



Future<void> loadFavorites() async {
  
  final prefs = await SharedPreferences.getInstance();
  List<String>? savedFavorites = prefs.getStringList('favorites');
  
  print("Saved favorites: $savedFavorites");

  if (savedFavorites != null && savedFavorites.isNotEmpty) {
    // Decode each JSON string in the list
    List<dynamic> jsonList = savedFavorites.map((e) => json.decode(e)).toList();

    // Map the JSON data to a list of FavoriteModel objects
    List<FavoriteModel> loadedFavorites = jsonList.map((item) => FavoriteModel.fromJson(item)).toList();

    _isFavoritesLoaded = true;

    // Update the favorites only if they have changed
    if (loadedFavorites != favorites) {
      favorites = loadedFavorites;
      print("Favorites loaded: ${favorites.join(', ')}");
      notifyListeners();
    }
  } else {
    print("No favorites found in SharedPreferences");
  }
}

  // Save favorites to SharedPreferences
Future<void> saveFavorites(List<FavoriteModel> favorites) async {
  final prefs = await SharedPreferences.getInstance();
  
  List<String> favoritesJsonList = favorites
      .map((favorite) => json.encode(favorite.toJson())) // Convert FavoriteModel to JSON string
      .toList();
  
  await prefs.setStringList('favorites', favoritesJsonList);
  print("Favorites saved: ${favoritesJsonList.length} items.");
}


// Add a favorite word and save it to SharedPreferences
void addFavorite(FavoriteModel word) {
  favorites.add(word);
  saveFavorites(favorites); 
}

// Remove a favorite word and update SharedPreferences
void removeFavorite(FavoriteModel word) {
  favorites.remove(word);
  saveFavorites(favorites);
}







}


