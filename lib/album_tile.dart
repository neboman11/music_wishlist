import 'package:flutter/material.dart';

class AlbumTile extends StatefulWidget {
  const AlbumTile({
    Key? key,
    required this.artist,
    required this.album,
    required this.image,
  }) : super(key: key);

  final String artist;
  final String album;
  final Image image;

  @override
  State<AlbumTile> createState() => _AlbumTileState();
}

class _AlbumTileState extends State<AlbumTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: widget.image,
        ),
        Text(
          widget.artist,
          style: const TextStyle(fontSize: 20),
        ),
        Text(widget.album),
      ],
    );
  }
}
