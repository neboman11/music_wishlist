import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'want_cd.dart';
import 'album.dart';
import 'album_tile.dart';

class AlbumGrid extends StatefulWidget {
  const AlbumGrid({
    Key? key,
    required this.addAlbum,
    required this.removeAlbum,
  }) : super(key: key);

  final void Function(Album) addAlbum;
  final void Function(Album) removeAlbum;

  @override
  State<AlbumGrid> createState() => _AlbumGridState();
}

class _AlbumGridState extends State<AlbumGrid> {
  void _addAlbumToRemoveList(Map<String, String> album) {
    if (album['selected'] == 'true') {
      widget.addAlbum(Album(album: album['album']!, artist: album['artist']!));
    } else {
      widget
          .removeAlbum(Album(album: album['album']!, artist: album['artist']!));
    }
  }

  Future<List<WantCD>> _fetchWantCDs() async {
    final response = await http
        .get(Uri.https('www.nesbitt.rocks', '/music-wishlist-api/wanted'));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((dynamic json) => WantCD.fromJson(json)).toList();
    } else {
      // If the server did not return a 200 OK response, then throw an exception.
      return Future.error('Failed to load album list');
    }
  }

  Future<String> _fetchCoverArtLink(String album, String artist) async {
    final response = await http
        .get(Uri.https('www.nesbitt.rocks', '/music-wishlist-api/cover', {
      'album': album,
      'artist': artist,
    }));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      return json.decode(response.body)['cover'];
    } else {
      // If the server did not return a 200 OK response, then throw an exception.
      return Future.error('Failed to load album cover');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WantCD>>(
      future: _fetchWantCDs(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400.0,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            itemBuilder: (context, index) {
              return Center(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  child: FutureBuilder<String>(
                    builder: (context, coverArtSnapshot) {
                      if (coverArtSnapshot.hasData) {
                        return AlbumTile(
                          onChanged: _addAlbumToRemoveList,
                          artist: snapshot.data![index].artist,
                          album: snapshot.data![index].album,
                          image: Image.network(
                            coverArtSnapshot.data!
                                .replaceFirst(RegExp(r'http:'), 'https:'),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        );
                      } else if (coverArtSnapshot.hasError) {
                        return AlbumTile(
                          onChanged: _addAlbumToRemoveList,
                          artist: snapshot.data![index].artist,
                          album: snapshot.data![index].album,
                          image: const Image(
                            image: AssetImage('assets/no_art.jpg'),
                          ),
                        );
                      }
                      // By default, show a loading spinner.
                      return const CircularProgressIndicator();
                    },
                    future: _fetchCoverArtLink(snapshot.data![index].album,
                            snapshot.data![index].artist)
                        .catchError((err) {
                      return 'assets/no_art.jpg';
                    }),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a loading spinner.
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
