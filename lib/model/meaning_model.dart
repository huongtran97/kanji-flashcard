class MeaningModel {
  final String meaning;
  final bool? primary;
  final bool acceptedAnswer;

  MeaningModel({
    required this.meaning,
    this.primary,
    required this.acceptedAnswer,
  });

  // Factory constructor to create a Meaning from a Map
  factory MeaningModel.fromJson(Map<String, dynamic> map) {
    return MeaningModel(
      meaning: map['meaning'] ?? '',
      primary: map['primary'] ?? false,
      acceptedAnswer: map['accepted_answer'] ?? false,
    );
  }

  // Method to convert the object back to a Map
  Map<String, dynamic> toJson() {
    return {
      'meaning': meaning,
      'primary': primary,
      'accepted_answer': acceptedAnswer,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MeaningModel) return false;
    return meaning == other.meaning &&
        primary == other.primary &&
        acceptedAnswer == other.acceptedAnswer;
  }

  @override
  int get hashCode =>
      meaning.hashCode ^ primary.hashCode ^ acceptedAnswer.hashCode;
}
