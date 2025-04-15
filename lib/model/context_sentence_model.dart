class ContextSentence {
  final String en;
  final String ja;

  ContextSentence({required this.en, required this.ja});

  factory ContextSentence.fromJson(Map<String, dynamic> json) {
    return ContextSentence(
      en: json['en'] ?? '',
      ja: json['ja'] ?? '',
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'en': en,
      'ja': ja,
    };
  }
}