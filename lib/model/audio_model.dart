class Audio {
  final String url;
  final Metadata metadata;
  final String contentType;

  Audio({
    required this.url,
    required this.metadata,
    required this.contentType,
  });

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      url: json['url'] ?? '',
      metadata: Metadata.fromJson(json['metadata']),
      contentType: json['content_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'metadata': metadata.toJson(), 
      'content_type': contentType,
    };
  }
}

class Metadata {
  final String gender;
  final int sourceId;
  final String pronunciation;
  final int voiceActorId;
  final String voiceActorName;
  final String voiceDescription;

  Metadata({
    required this.gender,
    required this.sourceId,
    required this.pronunciation,
    required this.voiceActorId,
    required this.voiceActorName,
    required this.voiceDescription,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      gender: json['gender'] ?? '',
      sourceId: json['source_id'] ?? 0,
      pronunciation: json['pronunciation'] ?? '',
      voiceActorId: json['voice_actor_id'] ?? 0,
      voiceActorName: json['voice_actor_name'] ?? '',
      voiceDescription: json['voice_description'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'source_id': sourceId,
      'pronunciation': pronunciation,
      'voice_actor_id': voiceActorId,
      'voice_actor_name': voiceActorName,
      'voice_description': voiceDescription,
    };
  }
} 