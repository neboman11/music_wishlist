class WantCD {
  final String artist;
  final String album;
  final int year;
  final String coverArtLink;

  WantCD({
    required this.artist,
    required this.album,
    required this.year,
    required this.coverArtLink,
  });

  factory WantCD.fromJson(Map<String, dynamic> json) {
    return WantCD(
      artist: json['Artist'],
      album: json['Album'],
      year: json['Year'],
      coverArtLink: json['CoverArt_Link'],
    );
  }
}
