import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prowes_motorizado/src/backend/models/pedido_model.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';
import 'package:prowes_motorizado/src/backend/services/pedidos_service.dart';
import 'package:prowes_motorizado/src/backend/services/usuario_services.dart';
import 'package:prowes_motorizado/src/backend/utils/distance.dart';
import 'package:prowes_motorizado/src/backend/utils/custom_dialog.dart';
import 'package:prowes_motorizado/src/frontend/pages/loading_window.dart';
import 'package:prowes_motorizado/src/backend/utils/location.dart';
import 'package:prowes_motorizado/src/backend/utils/snack_bar.dart';
import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AllOrders extends StatefulWidget {
  const AllOrders({Key? key}) : super(key: key);

  @override
  State<AllOrders> createState() => _PageLocationState();
}

class _PageLocationState extends State<AllOrders> {
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = [];
  final List<Polyline> _polyline = [];

  late PolylinePoints polylinePoints;

  List<List<LatLng>> latLines = [];
  LatLng LatVen = const LatLng(0, 0);

  PedidoService pedidoServ = PedidoService();

  late LatLng currentLocation;
  late LatLng destinationLocation;
  late CameraPosition _latacunga = const CameraPosition(
    target: LatLng(-0.9324760840048609, -78.61793541360251),
  );

  bool _isLoading = true;
  final _collapsedHeight = 75.0;

  PedidoService serv = PedidoService();
  UsuarioService userserv = UsuarioService();
  bool isadmin = false;
  List<int> renderTriggers = [0, 0];
  LatLng? motPos;
  int idp = 0;
  bool usingRoutes = true;

  @override
  void initState() {
    super.initState();

    if (_isLoading) {
      polylinePoints = PolylinePoints();
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    log("_initializeData loc");


    await _downloadAddres();


    for (var lL in latLines){
      await setRoutes(lL);
    }

    /*FirestoreManager.instance.subscribe(
      "OrdenDel",
      callback: () {
        var data = FirestoreManager.instance.subscriptions["OrdenDel"]["data"];
        log("DATA: $data");
        var pos = getLocation();

        //posf.then((pos) {
        var ped = serv.processPedidos(data, pos, true);
        ped.then((value) {
          if (mounted) {
            //pedido = value.first;
            setState(() {});
          }
        });
        //});
      },
    );*/
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    
  }

  _showSnackBar(String msg) {
    SnackBarTool.showSnackbar(context, text: msg);
  }

  @override
  void dispose() {
    /*FirestoreManager
        .instance.subscriptions["OrdenDel${widget.pedido.numPedido}"]["id"]
        .cancel();*/
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> content = json.decode(MainProvider.instance.data);

    isadmin = content["rol"] == "Administrador" ||
        content["rol"] == "Cliente";


    return Scaffold(
        appBar: AppBar(
          elevation: 10.h,
          leading: IconButton(
              padding: EdgeInsets.symmetric(horizontal: 0.h),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              iconSize: 20.h,
              tooltip: 'Regresar',
              color: Colors.black,
              onPressed: () {
                delayedPop(context, home: false);
              }),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  CustomColors.primaryColor,
                  CustomColors.primaryColor,
                  CustomColors.primaryColor
                ])),
          ),
          toolbarHeight: 60.h,
          centerTitle: true,
          title: Image.asset(
            //cambiar imagen
            'assets/images/Logo_3.png',
            fit: BoxFit.contain,
            height: 100.h,
            width: 100.h,
          ),
        ),
        body: _isLoading
            ? const LoadingIndicator()
            : Stack(children: [
                Container(
                  padding:
                      EdgeInsets.only(bottom: isadmin ? 0 : _collapsedHeight),
                  child: Builder(builder: (context) {
                      if (renderTriggers[0] == 0) {
                        _latacunga = CameraPosition(
                          target: LatVen,
                          zoom: 16,
                        );
                      }

                    log("LEN: ${_polyline.length}");

                    renderTriggers[0]++;
                    if (renderTriggers[0] > 10) {
                      renderTriggers[0] = 0;
                    }

                    return GoogleMap(
                      polylines: Set<Polyline>.of(_polyline),
                      markers: Set<Marker>.of(_markers),
                      mapType: MapType.normal,
                      initialCameraPosition: _latacunga,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    );
                  }),
                ),
              ]));
  }

  Future<List<LatLng>> generateRoute(List<LatLng> latLinesAux) async {
    List<LatLng> polylineCoordinates = [];

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyDxrtPdAdaFs06Q2P_ULt4pOB-Wms4n5gk",
        PointLatLng(latLinesAux[0].latitude, latLinesAux[0].longitude),
        PointLatLng(latLinesAux[1].latitude, latLinesAux[1].longitude),
        travelMode: TravelMode.driving,
      );

      if (result.status == "OK") {
        for (PointLatLng point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }

      var cont = json.decode(MainProvider.instance.data);

      var map = await FirestoreManager.instance
          .getData("UsuariosDel", uid: cont["uid"]);
      var profile = map.first;

      if (!profile["datos"].containsKey("api_calls")) {
        profile["datos"]["api_calls"] = 0;
      }
      profile["datos"]["api_calls"]++;
      await FirestoreManager.instance
          .postData("UsuariosDel", profile, edit: true, uid: cont["uid"]);
    } catch (e) {
      log('generateRoute(): $e');
    }

    return polylineCoordinates;
  }

  Polyline genPolyline(List<LatLng> polylineCoordinates, int id) {
    return Polyline(
        polylineId: PolylineId("route$id"),
        width: 5,
        color: colorAlAzar(),
        points: polylineCoordinates);
  }

  addRoute(List<LatLng> latLinesAux, int id,
      {Color color = Colors.black}) async {
    List<LatLng> polylineCoordinates = await generateRoute(latLinesAux);

    if (polylineCoordinates.isNotEmpty) {
      _polyline.add(genPolyline(polylineCoordinates, id));
    }
  }

  // Se necesita cuenta de pago para esto.
  setRoutes(List<LatLng> ll) async {
    log("setRoutes");
    await addRoute(ll, idp);
   
    if (_polyline.isEmpty) {
      log("Falló creando Rutas, usando Lineas Rectas...");
      usingRoutes = false;
      _obtenerlinea(ll, idp);
    }

    idp++;
  }

  _downloadAddres() async {
    log("downAddr()");

    var col = FirestoreManager.instance.firestore
          .collection("UsuariosDel")
          .where("rol", isEqualTo: "Administrador");

    var adl = await FirestoreManager.instance.getData("", collection: col);
    var admin = adl.first;

    var coords = admin["datos"]["coords"];

    _markers.add(Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        markerId: const MarkerId('Vendedor'),
        position: LatLng(double.parse(coords["lat"]), double.parse(coords["long"])),
        infoWindow: const InfoWindow(title: 'Vendedor')));
    
    LatVen = LatLng(double.parse(coords["lat"]), double.parse(coords["long"]));
    
    var content = json.decode(MainProvider.instance.data);

    var uid = isadmin ? "" : content["uid"];
    var list = await pedidoServ.getPedido(uid1: uid, prior: !isadmin);

    List<LatLng> lNGS = [];

    for (var order in list) {
      var com = order.comprador;

      var latCom = com!.lat;
      var longCom = com.long;

      var lngCom = LatLng(double.parse(latCom!), double.parse(longCom!));

      _markers.add(Marker(
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          markerId: const MarkerId('Comprador'),
          position: lngCom,
          infoWindow: const InfoWindow(title: 'Comprador')));

      lNGS.add(lngCom);
    }

    for (var l in lNGS) {
      latLines.add([LatVen, l]);
    }

    if (isadmin) {
      var col1 = FirestoreManager.instance.firestore
          .collection("UsuariosDel")
          .where("rol", isEqualTo: "Cliente");

    var cll = await FirestoreManager.instance.getData("", collection: col1);

    var motl = await FirestoreManager.instance.getData("UsuariosDel");

    for (int i = motl.length-1; i >= 0; i--) {
      var m = motl[i];
      if (cll.any((mapa) => mapa["uid"] == m["uid"])){
        motl.removeAt(i);
      } else if (adl.any((mapa) => mapa["uid"] == m["uid"])){
        motl.removeAt(i);
      }
    }

    for (var m in motl) {
      try {
        var coords = m["datos"]["coords"];
        motPos = LatLng(double.parse(coords["lat"]), double.parse(coords["long"]));

        final Uint8List markerIcon =
          await getBytesFromAsset('assets/images/bicicleta.png', 100);
      _markers.add(Marker(
          icon: BitmapDescriptor.fromBytes(markerIcon),
          markerId: const MarkerId('Motorizado'),
          position: motPos!,
          infoWindow: const InfoWindow(title: 'Motorizado')));
      } catch (e) {
        log("error motmapglobal: $e");
      }
    }
    }
    
  }

  Color colorAlAzar() {
    final random = math.Random();
    final index = random.nextInt(Colors.primaries.length);
    return Colors.primaries[index];
  }

  _obtenerlinea(List<LatLng> ll, int id) async {
      _polyline.add(Polyline(
        polylineId: PolylineId('route$id'),
        points: ll,
        color: colorAlAzar(),
        width: 6,
      ));
  }

  _setPolyline(int id, List<LatLng> lines, {bool force = false}) async {
    try {
      log("_setPolyline $lines");

      if (usingRoutes) {
        List<LatLng> polylineCoordinates = await generateRoute(lines);
        _polyline[id] = genPolyline(polylineCoordinates, id/*, Colors.orange*/);
      } else {
        _polyline[id] = Polyline(
          polylineId: PolylineId("route$id"),
          points: lines,
          color: Colors.orange,
          width: 6,
        );
      }
    } catch (e) {
      log("setPolyline Error: $e");
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<CameraPosition>('_Latacunga', _latacunga));
  }
}
