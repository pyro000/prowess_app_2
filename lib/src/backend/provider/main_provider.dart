import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';
import 'dart:convert';
import 'dart:developer';

class MainProvider extends ChangeNotifier {
  static final MainProvider _instance = MainProvider._privateConstructor();
  MainProvider._privateConstructor();
  static MainProvider get instance => _instance;
  
  bool _mode = false;
  String _lastLogin = "";
  String _data = "";
  String _location = "";

  String get data {
    return _data;
  }
  
  set data(String data) {
    _updateInstance("data", data);
    _data = data;
    notifyListeners();
  }

  String get location {
    return _location;
  }
  
  set location(String location) {
    _updateInstance("location", location);
    _location = location;
    notifyListeners();
  }

  bool get mode {
    return _mode;
  }

  set mode(bool value) {
    _updateInstance("mode", value.toString());
    _mode = value;
    notifyListeners();
  }

  String get lastLogin {
    return _lastLogin;
  }

  set lastLogin(String d) {
    _updateInstance("lastdate", d);
    _lastLogin = d;
    notifyListeners();
  }

  Future<bool> initPrefs() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _mode = prefs.getBool("mode") ?? true;
      _lastLogin = prefs.getString("lastdate") ?? "";
      _data = prefs.getString("data") ?? "";
      _location = prefs.getString("location") ?? "";
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _updateInstance(String id, String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(id, val);
  }
}
