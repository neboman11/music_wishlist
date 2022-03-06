class Album {
  final String artist;
  final String album;

  Album({
    required this.artist,
    required this.album,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      artist: json['Artist'],
      album: json['Album'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Artist': artist,
      'Album': album,
    };
  }
}
