class ReadingModel {
  final String reading;
  final String type;
  final bool primary;

  ReadingModel({
    required this.reading,
    required this.type,
    required this.primary,
  });
  // Factory constructor to create a Meaning from a Map
  factory ReadingModel.fromJson(Map<String, dynamic> json) {
    return ReadingModel(
      reading: json['reading'] ?? '',  
      type: json['type'] ?? '',        
      primary: json['primary'] ?? false, 
    );
  }
}
