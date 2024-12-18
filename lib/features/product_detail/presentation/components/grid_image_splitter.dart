import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

class GridImageSplitter extends StatefulWidget {
  final String imagePath;
  double animationValue;

  GridImageSplitter(
      {super.key, required this.animationValue, required this.imagePath});

  @override
  State<GridImageSplitter> createState() => _CustomGridImageSplitterState();
}

class _CustomGridImageSplitterState extends State<GridImageSplitter>
    with TickerProviderStateMixin {
  ui.Image? _image;
  final List<ui.Image> _gridImages = [];

  @override
  void initState() {
    super.initState();
    _loadImage();
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

  double horizontalTranslation(
      bool isLeft, bool isHorizontalRow, double screenWidth) {
    return (isLeft ? -(screenWidth / 2 - 50) : (screenWidth / 2 - 50)) *
        (1 - widget.animationValue / 200);
  }

  double verticalTranslation(
      bool isTop, bool isHorizontalRow, double screenHeight) {
    return isHorizontalRow
        ? (isTop ? -(screenHeight / 3 - 100) : (screenHeight / 3 - 50)) *
            (1 - widget.animationValue / 200)
        : 0;
  }

  Future<void> _splitImage() async {
    if (_image == null) return;

    final width = _image!.width;
    final height = _image!.height;

    // Specific handling for 900x1800 images
    final cellWidth = width == 900 ? 300 : width ~/ 3;
    final cellHeight = height == 1800 ? 600 : height ~/ 3;

    _gridImages.clear();

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
    // log("grid: ${_gridImages}");
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    double opacity = (widget.animationValue / 200).clamp(0.0, 1.0);

    Widget animatedContainer({
      required Color color,
      bool translateHorizontal = false,
      bool translateVertical = false,
      bool isLeft = false,
      bool isTop = false,
      required int index,
    }) {
      return Transform.translate(
        offset: Offset(
          translateHorizontal
              ? horizontalTranslation(isLeft, true, screenWidth)
              : 0,
          translateVertical
              ? verticalTranslation(isTop, true, screenHeight)
              : 0,
        ),
        child: Opacity(
            opacity: opacity,
            child: Container(
                margin: const EdgeInsets.all(1),
                width: 100,
                height: 100 * (_image!.height / _image!.width),
                child: index < _gridImages.length
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: RawImage(
                          image: _gridImages[index],
                          fit: BoxFit.cover,
                        ),
                      )
                    : const SizedBox.shrink())),
      );
    }

    return (_image == null)
        ? const SizedBox.shrink()
        : Stack(
            children: [
              Column(
                children: [
                  // 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      animatedContainer(
                          color: Colors.red,
                          translateHorizontal: true,
                          translateVertical: true,
                          isLeft: true,
                          isTop: true,
                          index: 0),
                      animatedContainer(
                          color: Colors.blue,
                          translateVertical: true,
                          index: 1,
                          isTop: true),
                      animatedContainer(
                          color: Colors.yellow,
                          translateHorizontal: true,
                          index: 2,
                          translateVertical: true,
                          isLeft: false,
                          isTop: true),
                    ],
                  ),
                  // 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      animatedContainer(
                          color: Colors.tealAccent,
                          translateHorizontal: true,
                          index: 3,
                          isLeft: true),
                      Opacity(
                          opacity: opacity,
                          child: Container(
                              margin: const EdgeInsets.all(1),
                              width: 100,
                              height: 100 * (_image!.height / _image!.width),
                              child: 4 < _gridImages.length
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: RawImage(
                                        image: _gridImages[4],
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const SizedBox.shrink())),
                      animatedContainer(
                          color: Colors.brown,
                          translateHorizontal: true,
                          index: 5,
                          isLeft: false),
                    ],
                  ),
                  // 3
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      animatedContainer(
                          color: Colors.purple,
                          translateHorizontal: true,
                          translateVertical: true,
                          index: 6,
                          isLeft: true,
                          isTop: false),
                      animatedContainer(
                        color: Colors.green,
                        translateVertical: true,
                        index: 7,
                      ),
                      animatedContainer(
                          color: Colors.orange,
                          translateHorizontal: true,
                          translateVertical: true,
                          index: 8,
                          isLeft: false,
                          isTop: false),
                    ],
                  ),
                ],
              ),
            ],
          );
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
