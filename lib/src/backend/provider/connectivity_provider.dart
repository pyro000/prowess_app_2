import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'package:prowes_motorizado/src/backend/utils/location.dart';

class ConnectivityProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  bool _isLocationEnabled = true;
  bool _isPermission = true;
  bool get isOnline => _isOnline;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get isPermission => _isPermission;
  int counter = 0;

  Future<void> initConectivity() async {
    try {
      var status = await _connectivity.checkConnectivity();

      if (status == ConnectivityResult.none) {
        if (_isOnline != false) {
          _isOnline = false;
          log("Lost Internet Connection");
          FirestoreManager.instance.connected = false;
          FirestoreManager.instance.firestore = null;
        }
      } else {
        if (_isOnline != true) {
          FirestoreManager.instance.connect();
          _isOnline = true;
          log("Connected to Internet");
        }
      }

      var status1 = await Geolocator.isLocationServiceEnabled();

      if (!status1) {
        _isLocationEnabled = false;

        if (_isLocationEnabled != false) {
          _isLocationEnabled = false;
          log("No Location Enabled");
        }
      } else {
        if (_isLocationEnabled != true) {
          _isLocationEnabled = true;
          log("Location Enabled");
        }
      }

      if (_isLocationEnabled) {
        var status2 = await Geolocator.checkPermission();

        //log("$status2");

        if (status2 == LocationPermission.denied ||
            status2 == LocationPermission.deniedForever) {
          status2 = await Geolocator.requestPermission();

          if (_isPermission != false) {
            _isPermission = false;
            log("No Permissions Found");
          }
        } else {
          if (_isPermission != true) {
            _isPermission = true;
            log("Permissions Enabled");
          }
        }
      }

      if (_isPermission && counter == 0) {
        var pos = await determinarPosicion();
        var loc = "${pos.latitude}/${pos.longitude}";
        MainProvider.instance.location = loc;
        //log("$loc");
      }

      if (counter > 100) {
        counter = 0;
      } else {
        counter++;
      }

      notifyListeners();
    } on PlatformException catch (e) {
      log("PlataformException: $e");
    }
  }
}
