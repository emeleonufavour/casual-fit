import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;

class GridImageSplitter extends StatefulWidget {
  final String imagePath;

  const GridImageSplitter({super.key, required this.imagePath});

  @override
  State<GridImageSplitter> createState() => _CustomGridImageSplitterState();
}

class _CustomGridImageSplitterState extends State<GridImageSplitter> {
  ui.Image? _image;
  final List<ui.Image> _gridImages = [];
  List<Offset> _positions = List.generate(3, (index) => Offset(0, 0));

  @override
  void initState() {
    super.initState();

    _loadImage();
  }

  // Function to animate positions
  void _animatePositions() {
    setState(() {
      // Modify positions to animate the containers
      _positions = List.generate(
        3,
        (index) => Offset((index % 2 == 0) ? 50.0 : 150.0, (index + 1) * 50.0),
      );
    });
  }

  Future<void> _loadImage() async {
    final ByteData data = await rootBundle.load(widget.imagePath);
    final ui.Codec codec =
        await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo fi = await codec.getNextFrame();

    setState(() {
      _image = fi.image;
      _splitImage();
    });
  }

  void _splitImage() {
    if (_image == null) return;

    final width = _image!.width;
    final height = _image!.height;

    // Specific handling for 900x1800 images
    final cellWidth = width == 900 ? 300 : width ~/ 3;
    final cellHeight = height == 1800 ? 600 : height ~/ 3;

    _gridImages.clear();

    // Split the image into 9 grid cells
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        _captureSubImage(
            _image!, col * cellWidth, row * cellHeight, cellWidth, cellHeight);
      }
    }
  }

  Future<void> _captureSubImage(
      ui.Image originalImage, int x, int y, int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImageRect(
        originalImage,
        Rect.fromLTWH(
            x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble()),
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        Paint());

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);

    setState(() {
      _gridImages.add(image);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _image == null
        ? CircularProgressIndicator()
        : GestureDetector(
            onTap: _animatePositions,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.5,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _gridImages.length,
              itemBuilder: (context, index) {
                // Regular cells
                return FutureBuilder<Uint8List>(
                    future: _convertToUint8List(_gridImages[index]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      return AnimatedContainer(
                        duration: Duration(seconds: 3),
                        curve: Curves.easeInOut,
                        transform: Matrix4.translationValues(
                            _positions[index % 3].dx,
                            _positions[index % 3].dy,
                            0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: MemoryImage(snapshot.data!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    });
              },
            ),
          );
  }

  Future<Uint8List> _convertToUint8List(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  void dispose() {
    _image?.dispose();
    for (var img in _gridImages) {
      img.dispose();
    }
    super.dispose();
  }
}
