import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveCurrentWord(String word) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('currentWord', word);  // Save the word in SharedPreferences
}

Future<String?> loadCurrentWord() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('currentWord');  // Retrieve the saved word
}

