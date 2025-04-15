class ReadingModel {
  final String reading;
  final bool primary;
  final bool acceptedAnswer;

  ReadingModel({
    required this.reading,
    required this.acceptedAnswer,
    required this.primary,
  });

  // Factory constructor to create a ReadingModel from a Map
  factory ReadingModel.fromJson(Map<String, dynamic> json) {
    return ReadingModel(
      reading: json['reading'] ?? '',
      acceptedAnswer: json['accepted_answer'] ?? false,        
      primary: json['primary'] ?? false, 
    );
  }

  // From ReadingModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'reading': reading,
      'accepted_answer': acceptedAnswer,
      'primary': primary,
    };
  }

  // Compare objects
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingModel &&
        other.reading == reading &&
        other.acceptedAnswer == acceptedAnswer &&
        other.primary == primary;
  }

  @override
  int get hashCode => reading.hashCode ^ acceptedAnswer.hashCode ^ primary.hashCode;

   @override
  String toString() {
    return 'ReadingModel(reading: $reading)';
  }
}
