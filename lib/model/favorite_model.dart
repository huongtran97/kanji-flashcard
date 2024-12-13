// import 'package:japanese_flashcard_application/model/meaning_model.dart';

class FavoriteModel {
  final String word;
  final List<String> onyomiReadings;
  final List<String> kunyomiReadings;
  final List<String> nanoriReadings;
  // final List<WordMeaning> wordMeanings;

  FavoriteModel({
    required this.word,
    required this.onyomiReadings,
    required this.kunyomiReadings,
    required this.nanoriReadings,
    // required this.wordMeanings,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FavoriteModel &&
        other.word == word &&
        other.onyomiReadings == onyomiReadings &&
        other.kunyomiReadings == kunyomiReadings &&
        other.nanoriReadings == nanoriReadings ;
        // other.wordMeanings == wordMeanings;
  }

  @override
  int get hashCode {
    return word.hashCode ^
        onyomiReadings.hashCode ^
        kunyomiReadings.hashCode ^
        nanoriReadings.hashCode ;
        // wordMeanings.hashCode;
  }
}

