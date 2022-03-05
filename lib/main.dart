import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_wishlist/album_tile.dart';

import 'want_cd.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Michael\'s Music Wishlist',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Michael\'s Music Wishlist'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<WantCD>> fetchWantCDs() async {
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

  Future<String> fetchCoverArtLink(String album, String artist) async {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 8.0, left: 5.0, right: 5.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/cd_music.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<List<WantCD>>(
          future: fetchWantCDs(),
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
                              artist: snapshot.data![index].artist,
                              album: snapshot.data![index].album,
                              image: Image.network(
                                coverArtSnapshot.data!,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                              ),
                            );
                          } else if (coverArtSnapshot.hasError) {
                            return AlbumTile(
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
                        future: fetchCoverArtLink(snapshot.data![index].album,
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
        ),
      ),
    );
  }
}
