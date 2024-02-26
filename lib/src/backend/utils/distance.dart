import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer';// as dev;
//import 'package:prowes_motorizado/src/firestore/firestore_manager.dart';

double calculateDistance(List<LatLng> polyline) {
  log("calculateDistance()");
  double totalDistance = 0.0;

  for (int i = 0; i < polyline.length - 1; i++) {
    final lat1 = polyline[i].latitude;
    final lon1 = polyline[i].longitude;
    final lat2 = polyline[i + 1].latitude;
    final lon2 = polyline[i + 1].longitude;

    final distance = _calculateDistanceHaversine(lat1, lon1, lat2, lon2);
    totalDistance += distance;
  }

  return double.parse(
      totalDistance.toStringAsFixed(2)); //Solución mediocre, pero ya qué
}

Future<double> calculateOrderDistance(Map<String, dynamic> item, LatLng pos) async {
  
  var com = item["ord_cliente"];
  var ven = item["ord_vendedor"];

  double latCom;
  double longCom;

  try {
    latCom = double.parse(com["datos"]["coords"]["lat"]);
    longCom = double.parse(com["datos"]["coords"]["long"]);
  } catch (e) {
    latCom = com["datos"]["coords"]["lat"];
    longCom = com["datos"]["coords"]["long"];
  }

  var latVen = double.parse(ven["datos"]["coords"]["lat"]);
  var longVen = double.parse(ven["datos"]["coords"]["long"]);

  var latLines = [LatLng(latCom, longCom), LatLng(latVen, longVen)];

  var latLines1 = [
    LatLng(latVen, longVen),
    pos
  ];

  var dis1 = calculateDistance(latLines);
  var dis2 = calculateDistance(latLines1);

  log("CalculateOrderDistance");

  return dis1 + dis2;
}

double _calculateDistanceHaversine(
    double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371; // Radio de la Tierra en kilómetros

  // Convierte de grados a radianes
  final lat1Rad = degreesToRadians(lat1);
  final lon1Rad = degreesToRadians(lon1);
  final lat2Rad = degreesToRadians(lat2);
  final lon2Rad = degreesToRadians(lon2);

  final dlat = lat2Rad - lat1Rad;
  final dlon = lon2Rad - lon1Rad;

  final a = math.sin(dlat / 2) * math.sin(dlat / 2) +
      math.cos(lat1Rad) * math.cos(lat2Rad) * math.sin(dlon / 2) * math.sin(dlon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  final distance = earthRadius * c;

  return distance;
}

double degreesToRadians(double degrees) {
  return degrees * math.pi / 180;
}
 