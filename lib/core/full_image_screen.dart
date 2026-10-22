import 'dart:io';

import 'package:flutter/material.dart';

/// Obrázek přes celou obrazovku, jde přibližovat dvěma prsty.
class FullImageScreen extends StatelessWidget {
  const FullImageScreen({super.key, required this.title, required this.path});
  final String title;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(title)),
      body: InteractiveViewer(
        minScale: 1,
        maxScale: 6,
        child: Center(child: Image.file(File(path))),
      ),
    );
  }
}

void openFullImage(BuildContext context, String title, String path) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => FullImageScreen(title: title, path: path),
    ),
  );
}
