import 'package:japanese_flashcard_application/model/meaning_model.dart';
import 'package:japanese_flashcard_application/model/reading_model.dart';

class Kanji {
  final int level;
  final String characters;
  final List<WordMeaning> wordMeanings;
  final List<ReadingModel> readings;

  Kanji({
    required this.level,
    required this.characters,
    required this.wordMeanings,
    required this.readings,
  });
  // Factory constructor to create a Meaning from a Map
  factory Kanji.fromJson(Map<String, dynamic> json) {
    return Kanji(
      level: json['data']['level'],
      characters: json['data']['characters'],
      wordMeanings: (json['data']['meanings'] as List)
          .map((meaning) => WordMeaning.fromJson(meaning))
          .toList(),
      readings: (json['data']['readings'] as List)
          .map((reading) => ReadingModel.fromJson(reading))
          .toList(),
    );
  }

  
}
