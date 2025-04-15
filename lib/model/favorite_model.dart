
import 'package:flutter/foundation.dart';
import 'package:japanese_flashcard_application/model/reading_model.dart';

class FavoriteModel {
  
  final String kanji;
  final List<ReadingModel> readings;
  final List<String> meanings;
  


  FavoriteModel({
   
    required this.kanji,
    required this.readings,
    required this.meanings,
    
  });

  // From JSON to FavoriteModel
  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
     
      kanji: json['characters'] ?? '' ,
      readings: (json['readings'] as List<dynamic>)
          .map((item) => ReadingModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      meanings: List<String>.from(json['meanings'] as List<dynamic>),
    );
  }

  // From FavoriteModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'characters': kanji,
      'readings': readings.map((reading) => reading.toJson()).toList(),
      'meanings': meanings,
    };
  }

  // Compare objects
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteModel &&
        other.kanji == kanji &&
        listEquals(other.readings, readings) &&
        listEquals(other.meanings, meanings);
  }

  @override
  int get hashCode => kanji.hashCode ^ readings.hashCode ^ meanings.hashCode;

 
  @override
  String toString() {
    return 'FavoriteModel(characters: $kanji, readings: ${readings.map((reading) => reading.toString()).join(', ')}, meanings: $meanings)';
  }
}
