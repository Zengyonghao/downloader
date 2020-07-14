import 'dart:io';

import 'package:flutter/cupertino.dart';

class ItemBean with ChangeNotifier {
  String _path;
  String _sku;
  String _result;
  int _state;
  num _size = 0.0;
  String _msg;
  String _realUrl;
  String _outName;
  String _outPath;
  int _currentSize;
  int _index = 1;

  double _progress = 0;

  @override
  String toString(){
    return path;
  }

  double get progress => _progress;

  set progress(double value) {
    _progress = value;
  }

  int get index => _index;

  set index(int value) {
    _index = value;
  }

  String get outPath => _outPath;

  set outPath(String value) {
    _outPath = value;
  }

  int get currentSize => _currentSize;

  set currentSize(int value) {
    _currentSize = value;
  }

  String get realUrl => _realUrl;

  set realUrl(String value) {
    _realUrl = value;
  }

  String get msg => _msg;

  set msg(String value) {
    _msg = value;
  }

  String get outName => _outName;

  set outName(String value) {
    _outName = value;
  }

  num get size => _size;

  set size(num value) {
    _size = value;
  }

  String get sku => _sku;

  set sku(String value) {
    _sku = value;
  }

  String get path => _path;

  set path(String value) {
    _path = value;
    notifyListeners();
  }

  String get result => _result;

  int get state => _state;

  set state(int value) {
    _state = value;
    notifyListeners();
  }

  set result(String value) {
    _result = value;
  }
}
