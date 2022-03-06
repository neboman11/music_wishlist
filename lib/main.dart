import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:music_wishlist/album_grid.dart';
import 'package:music_wishlist/album_tile.dart';

import 'want_cd.dart';
import 'album.dart';

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
  final List<Album> _albumsToRemove = [];
  Widget? _albumGrid;

  void _addAlbum(Album album) {
    setState(() {
      _albumsToRemove.add(album);
    });
  }

  void _removeAlbum(Album album) {
    setState(() {
      _albumsToRemove.remove(album);
    });
  }

  void _resetAlbumGrid() {
    setState(() {
      _albumGrid = null;
      _albumGrid = AlbumGrid(addAlbum: _addAlbum, removeAlbum: _removeAlbum);
    });
  }

  @override
  Widget build(BuildContext context) {
    _resetAlbumGrid();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              child: const Text('Delete Selected'),
              onPressed: () {
                showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Confirm Deletion'),
                    content: const Text(
                        'Are you sure you want to delete the selected albums?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final response = await http.delete(
                              Uri.https('www.nesbitt.rocks',
                                  '/music-wishlist-api/delete'),
                              body: json.encode(_albumsToRemove
                                  .map((Album album) => album.toJson())
                                  .toList()));
                          if (response.statusCode == 200) {
                            _resetAlbumGrid();
                            Navigator.pop(context, true);
                          } else {
                            _resetAlbumGrid();
                            Navigator.pop(context, false);
                          }
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 8.0, left: 5.0, right: 5.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/cd_music.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: _albumGrid,
      ),
    );
  }
}
