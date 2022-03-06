import 'package:flutter/material.dart';

class AlbumTile extends StatefulWidget {
  const AlbumTile({
    Key? key,
    required this.artist,
    required this.album,
    required this.image,
    required this.onChanged,
  }) : super(key: key);

  final String artist;
  final String album;
  final Image image;
  final ValueChanged<Map<String, String>> onChanged;

  @override
  State<AlbumTile> createState() => _AlbumTileState();
}

class _AlbumTileState extends State<AlbumTile> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onChanged({
          'artist': widget.artist,
          'album': widget.album,
          'selected': _isSelected.toString(),
        });
        setState(() {
          _isSelected = !_isSelected;
        });
      },
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: widget.image,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  alignment: Alignment.topRight,
                  child: Checkbox(
                      value: _isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          _isSelected = value ?? false;
                        });
                      }),
                ),
              ],
            ),
          ),
          Text(
            widget.artist,
            style: const TextStyle(fontSize: 20),
          ),
          Text(widget.album),
        ],
      ),
    );
  }
}
