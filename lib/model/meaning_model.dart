class WordMeaning {
  final String meaning;
  final bool primary;
  final bool acceptedAnswer;

  WordMeaning({
    required this.meaning,
    required this.primary,
    required this.acceptedAnswer,
  });

  // Factory constructor to create a Meaning from a Map
  factory WordMeaning.fromJson(Map<String, dynamic> map) {
    return WordMeaning(
      meaning: map['meaning'] ?? '',
      primary: map['primary'] ?? false,
      acceptedAnswer: map['accepted_answer'] ?? false,
    );
  }


}
