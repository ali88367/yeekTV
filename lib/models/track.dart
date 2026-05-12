int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class Track {
  final int sequence;
  final String title;
  final String description;
  final int duration;
  final String durationString;
  final int elapsedDuration;
  final String url;
  final String id;
  final String thumbnail;
  final String mp3Url;
  final String artist;
  final String album;
  final int year;
  final List<double> waveformData;

  Track({
    required this.sequence,
    required this.title,
    required this.description,
    required this.duration,
    required this.durationString,
    required this.elapsedDuration,
    required this.url,
    required this.id,
    required this.thumbnail,
    required this.mp3Url,
    required this.artist,
    required this.album,
    required this.year,
    required this.waveformData,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      sequence: _toInt(json['sequence']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: _toInt(json['duration']),
      durationString: json['duration_string'] ?? '',
      elapsedDuration: _toInt(json['elapsedDuration']),
      url: json['url'] ?? '',
      id: json['id'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      mp3Url: json['mp3_url'] ?? '',
      artist: json['artist'] ?? '',
      album: json['album'] ?? '',
      year: _toInt(json['year']),
      waveformData:
          (json['waveformData'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sequence': sequence,
      'title': title,
      'description': description,
      'duration': duration,
      'duration_string': durationString,
      'elapsedDuration': elapsedDuration,
      'url': url,
      'id': id,
      'thumbnail': thumbnail,
      'mp3_url': mp3Url,
      'artist': artist,
      'album': album,
      'year': year,
      'waveformData': waveformData,
    };
  }
}

class PositionData {
  final Track track;
  final double positionInTrack;

  PositionData({required this.track, required this.positionInTrack});
}
