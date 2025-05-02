import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:stress_management/assets_const.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import '../models/image_model/image_model.dart';

class MainProvider extends ChangeNotifier {

  User? _user;

  User? get user => _user;

  void clearUserData() {
    _user = null;
    notifyListeners();
  }

  MainProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  List<ImageModelData> animalList = [];
  List<ImageModelData> flowersList = [];
  List<ImageModelData> mattersList = [];
  List<ImageModelData> plantsList = [];
  List<ImageModelData> simpleList = [];
  List<ImageModelData> mediumList = [];
  List<ImageModelData> complexList = [];

  List<ImageModelData> savedImageList = [];
  ImageModel? imageModel;
  ui.Image? img;

  final LocalStorage storage = LocalStorage('coloring_app');

  Future<void> loadData() async {
    // Clear existing lists first
    simpleList.clear();
    mediumList.clear();
    complexList.clear();

    // Add items from assets
    AssetsConst.simple.asMap().forEach((key, value) {
      simpleList.add(ImageModelData(path: value));
    });
    AssetsConst.medium.asMap().forEach((key, value) {
      mediumList.add(ImageModelData(path: value));
    });
    AssetsConst.complex.asMap().forEach((key, value) {
      complexList.add(ImageModelData(path: value));
    });

    notifyListeners();
  }

  void setImage(ui.Image? image) {
    img = image;
    notifyListeners();
  }

  Future<void> saveImage({required String name, int? index}) async {
    print("save image");
    print("name----------------->$name");
    if (img != null) {
      print("null değil");
      var pngBytes = await img!.toByteData(format: ui.ImageByteFormat.png);
      Directory appDocDir = await getTemporaryDirectory();
      String appDocPath = appDocDir.path;
      File file = File("$appDocPath/${name}.png")
        ..writeAsBytesSync(pngBytes!.buffer.asInt8List());
      if (index != null) {
        savedImageList.removeAt(index);
        savedImageList.add(ImageModelData(path: file.path));
        notifyListeners();
      } else {
        savedImageList.add(ImageModelData(path: file.path));
      }
      _saveToStorage(savedImageList);
    }
  }

  Future<void> deleteImage({int? index}) async {
    if (savedImageList.isNotEmpty && index != null) {
      savedImageList.removeAt(index);
      _saveToStorage(savedImageList);
      notifyListeners();
    }
  }

  Future<void> _saveToStorage(List<ImageModelData> list) async {
    imageModel = ImageModel(data: list);
    storage.setItem('colored_images',  imageModel!.toJson());
  }

  Future<void> getImageList() async {
    await storage.ready;
    var items = await storage.getItem('colored_images');
    if (items != null) {
      imageModel = ImageModel.fromJson(items);
      savedImageList = imageModel?.data ?? [];
    }
    notifyListeners();
  }


}
