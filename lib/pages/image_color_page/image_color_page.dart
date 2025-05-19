import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stress_management/values/icons/eraser_icon_icons.dart';
import 'package:stress_management/widgets/palette_widget/palette_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:zoom_widget/zoom_widget.dart';
import 'dart:ui' as ui;
import '../../packages/image_flood_fill/floodfill_image.dart';
import '../../providers/main_provider.dart';

class ImageColorPage extends StatefulWidget {
  final String? title;
  final String? path;
  final String? asset;
  final int? index;
  final File? file;

  const ImageColorPage({Key? key, this.title, this.path, this.file, this.index, this.asset,})
      : super(key: key);

  @override
  _ImageColorPageState createState() => _ImageColorPageState();
}

class _ImageColorPageState extends State<ImageColorPage> {
  Color _fillColor = Colors.white;
  Color _colorize = Colors.white;
  int index = 0;
  double h = 600;
  double w = 600;

  // create some values
  Color pickerColor = Color(0xffffffff);
  double _currentSliderValue = 20;
  int _currentPaletteIndex = 4;

  late final ImageProvider imageProvider;
  late Stopwatch _stopwatch;
  late Timer _timer;
  bool _isZooming = false;
  bool _isPanning = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {});
    if (widget.path != null) {
      imageProvider = AssetImage(widget.path!);
    } else {
      imageProvider = FileImage(widget.file!);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                setState(() {
                  _fillColor = pickerColor;
                  _colorize = pickerColor;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  // Define multiple color palettes
  final List<List<Color>> _colorPalettes = [
    [
      Color(0xFF1B2A49), // deepNavy
      Color(0xFF3E4A33), // darkOliveGreen
      Color(0xFFA14D3A), // burntSienna
      Color(0xFF2B616D), // deepTeal
      Color(0xFF6C4A63), // mutedPlum
      Color(0xFF4A4E69), // charcoalGray
      Color(0xFFB4A69B), // warmSand
      Color(0xFF64232E), // darkMaroon
    ],
    [
      Color(0xFFE8A87C), // Soft Peach
      Color(0xFFF6A6B2), // Blush Pink
      Color(0xFFB8DE6F), // Fresh Lime Green
      Color(0xFFA6CFE2), // Gentle Sky Blue
      Color(0xFF8066C2), // Soft Lavender
      Color(0xFFFAE596), // Sunny Yellow
      Color(0xFFB9936C), // Warm Beige
      Color(0xFFD85A7F), // Raspberry Rose
    ],
    [
      Color(0xFFFFC3A0), // Pastel Peach (Happiness)
      Color(0xFF84DCC6), // Soft Mint (Calmness)
      Color(0xFFB5A4E6), // Lavender Mist (Stress)
      Color(0xFFFF8C94), // Coral Pink (Energy)
      Color(0xFFA1C6EA), // Serenity Blue (Calmness)
      Color(0xFFF4D06F), // Warm Gold (Energy)
      Color(0xFFD499B9), // Soft Rosewood (Happiness)
      Color(0xFF6495ED), // Cornflower Blue (Calmness)
    ],
    [
      Color(0xFF92A8D1), // Dusty Blue (Calmness)
      Color(0xFFF7CAC9), // Soft Blush (Happiness)
      Color(0xFFFFA07A), // Light Coral (Energy)
      Color(0xFFB39BC8), // Deep Lavender (Stress)
      Color(0xFF52C2B2), // Turquoise Teal (Calmness)
      Color(0xFFFAE3B0), // Soft Lemon (Energy)
      Color(0xFFEC96A4), // Warm Pink (Happiness)
      Color(0xFF8C7AA9), // Muted Purple (Stress)
    ],
    [
      Color(0xFFADEFD1), // Fresh Aqua Green (Calmness)
      Color(0xFFFF6B6B), // Vibrant Coral (Happiness)
      Color(0xFFA29BFE), // Soft Periwinkle (Stress)
      Color(0xFF6AB187), // Gentle Forest Green (Calmness)
      Color(0xFFFFC857), // Warm Amber (Energy)
      Color(0xFF77C3EC), // Bright Sky Blue (Calmness)
      Color(0xFFEE6C4D), // Fiery Orange (Energy)
      Color(0xFFD8B4E2), // Light Orchid (Happiness)
    ],
  ];



  void _changeColorPalette(int index) {
    setState(() {
      _currentPaletteIndex = index;
    });
  }
  Future<void> _submitColoring() async {
    _stopwatch.stop();
    int colorDuration = _stopwatch.elapsed.inSeconds;
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "Unknown";
    String imageName = widget.path?.split('/').last ?? widget.file?.path.split('/').last ?? "Unknown";
    String? imageType = widget.asset;

    await FirebaseFirestore.instance.collection('coloring_logs').add({
      'user_id': userId,
      'image_name': imageName,
      'color_duration': colorDuration,
      'color_palette_id': _currentPaletteIndex,
      'image_type': imageType,
      'timestamp': Timestamp.now(),
    });

    Get.snackbar("Success", "Coloring saved successfully!");
    Get.back();
    Navigator.pop(context);
  }

  Future<void> _showPaletteSelectionDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Color Palette'),
          content: SingleChildScrollView(
            child: Column(
              children: List.generate(_colorPalettes.length, (index) {
                return GestureDetector(
                  onTap: () {
                    _changeColorPalette(index);
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: _colorPalettes[index]
                          .map((color) => Container(
                        width: 15,
                        height: 30,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ))
                          .toList(),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (widget.path != null) {
          await context
              .read<MainProvider>()
              .saveImage(name: widget.path!.split('/').last);
        } else {
          await context.read<MainProvider>().saveImage(
              name: widget.file!.path.split('/').last, index: widget.index);
        }
        return Future.value(true);
      },
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: <Widget>[
              buildRow(),
              Expanded(
                child: Container(
                  width: w,
                  child: Zoom(
                    maxZoomHeight: 5000,
                    maxZoomWidth: 5000,
                    initZoom: 0,
                    child: Center(
                      child: FloodFillImage(
                        imageProvider: imageProvider,
                        fillColor: _fillColor,
                        avoidColor: [Colors.transparent, Colors.black],
                        tolerance: 19,
                        onFloodFillEnd: (img) {
                          context.read<MainProvider>().setImage(img);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 70,
                child: selectedColorPalette(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SingleChildScrollView selectedColorPalette() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _colorPalettes[_currentPaletteIndex].map((color) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _fillColor = color;
                _colorize = color;
              });
            },
            child: Container(
              width: 40,
              height: 40,
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _fillColor == color ? Colors.black : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildRow() {
    return Container(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (widget.path != null) {
                context
                    .read<MainProvider>()
                    .saveImage(name: widget.path!.split('/').last);
              } else {
                context.read<MainProvider>().saveImage(
                    name: widget.file!.path.split('/').last, index: widget.index);
              }
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: Icon(EraserIcon.icon_eraser),
            onPressed: () {
              setState(() {
                _fillColor = Colors.white;
                _colorize = Colors.white;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.palette),
            onPressed: _showPaletteSelectionDialog,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _submitColoring,
          ),
        ],
      ),
    );
  }
}
