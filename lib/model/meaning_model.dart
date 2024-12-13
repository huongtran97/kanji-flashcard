class WordMeaningModel {
  final String meaning;
  final bool primary;
  final bool acceptedAnswer;

  WordMeaningModel({
    required this.meaning,
    required this.primary,
    required this.acceptedAnswer,
  });

  // Factory constructor to create a Meaning from a Map
  factory WordMeaningModel.fromJson(Map<String, dynamic> map) {
    return WordMeaningModel(
      meaning: map['meaning'] ?? '',
      primary: map['primary'] ?? false,
      acceptedAnswer: map['accepted_answer'] ?? false,
    );
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // Same reference
    if (other is! WordMeaningModel) return false; // Not the same type
    return meaning == other.meaning &&
        primary == other.primary &&
        acceptedAnswer == other.acceptedAnswer;
  }

  @override
  int get hashCode =>
      meaning.hashCode ^ primary.hashCode ^ acceptedAnswer.hashCode;
}
