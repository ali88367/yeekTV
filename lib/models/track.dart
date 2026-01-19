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
      sequence: json['sequence'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? 0,
      durationString: json['duration_string'] ?? '',
      elapsedDuration: json['elapsedDuration'] ?? 0,
      url: json['url'] ?? '',
      id: json['id'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      mp3Url: json['mp3_url'] ?? '',
      artist: json['artist'] ?? '',
      album: json['album'] ?? '',
      year: json['year'] ?? 0,
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
