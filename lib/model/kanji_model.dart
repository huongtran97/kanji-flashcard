import 'package:japanese_flashcard_application/model/audio_model.dart';
import 'package:japanese_flashcard_application/model/context_sentence_model.dart';
import 'package:japanese_flashcard_application/model/meaning_model.dart';
import 'package:japanese_flashcard_application/model/reading_model.dart';


class Kanji {
  final int level;
  final String characters;
  final String slug;
  final List<MeaningModel> meanings;
  final List<ReadingModel> readings;
  final List<ContextSentence> contextSentences;  
  final List<Audio> audios;
  

  Kanji({
    required this.level,
    required this.characters,
    required this.slug,
    required this.meanings,
    required this.readings,
    required this.contextSentences,  
    required this.audios,
  });

factory Kanji.fromJson(Map<String, dynamic> json) {
  final data = json['data'] ?? {};

  return Kanji(
    level: data['level'] ?? 0,
    characters: data['characters'] ?? "Unknown",
    slug: data['slug'] ?? "Unknown",
    meanings: (data['meanings'] as List? ?? [])
        .map((meaning) => MeaningModel.fromJson(meaning))
        .toList(),
    readings: (data['readings'] as List? ?? [])
        .map((reading) => ReadingModel.fromJson(reading))
        .toList(),
    contextSentences: (data['context_sentences'] as List? ?? [])
        .map((sentence) => ContextSentence.fromJson(sentence))
        .toList(),
    audios: (data['pronunciation_audios'] as List? ?? [])
        .map((audio) => Audio.fromJson(audio))
        .toList(),
  );
}


Map<String, dynamic> toJson() {
  return {
    'level': level,
    'characters': characters,
    'slug': slug,
    'meanings': meanings.map((meaning) => meaning.toJson()).toList(),
    'readings': readings.map((reading) => reading.toJson()).toList(),
    'context_sentences': contextSentences.map((sentence) => sentence.toJson()).toList(),
    'pronunciation_audios': audios.map((audio) => audio.toJson()).toList(),
  };
}



  
}
