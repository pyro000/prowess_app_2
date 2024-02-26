import 'dart:async';
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

class PageLocation extends StatefulWidget {
  const PageLocation({Key? key, required this.pedido}) : super(key: key);
  final Pedido pedido;

  @override
  State<PageLocation> createState() => _PageLocationState();
}

class _PageLocationState extends State<PageLocation> {
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = [];
  final List<Polyline> _polyline = [];

  late PolylinePoints polylinePoints;

  List<LatLng> latLines = [];
  List<LatLng> latLines2 = [];

  String? phoneCom, phoneVen, nameCom, nameVen;

  LatLng? _position;

  //int apicalls = 0;

  late LatLng currentLocation;
  late LatLng destinationLocation;

  final TextEditingController _textController = TextEditingController();

  late CameraPosition _latacunga = const CameraPosition(
    target: LatLng(-0.9324760840048609, -78.61793541360251),
  );

  bool _isLoading = true;
  late String idPedido = "";
  late String estado = "";
  late Pedido pedido = widget.pedido;

  final _collapsedHeight = 75.0;

  PedidoService serv = PedidoService();
  UsuarioService userserv = UsuarioService();
  bool isadmin = false;
  List<int> renderTriggers = [0, 0];
  LatLng? motPos;
  Map<String, dynamic> order = {};

  bool usingRoutes = true;

  @override
  void initState() {
    super.initState();

    if (_isLoading) {
      idPedido = widget.pedido.numPedido!;
      polylinePoints = PolylinePoints();
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    log("_initializeData loc");

    var map = await serv.getPedido(uid: idPedido);
    pedido = map.first;
    estado = pedido.estado ?? "";

    await _obtenerPosicion();
    await _downloadAddres();
    await setRoutes();

    FirestoreManager.instance.subscribe(
      "OrdenDel",
      callback: () {
        var data = FirestoreManager.instance.subscriptions["OrdenDel"]["data"];
        log("DATA: $data");
        var pos = getLocation();

        //posf.then((pos) {
        var ped = serv.processPedidos(data, pos, true);
        ped.then((value) {
          if (mounted) {
            pedido = value.first;
            setState(() {});
          }
        });
        //});
      },
    );

    _isLoading = false;
  }

  _showSnackBar(String msg) {
    SnackBarTool.showSnackbar(context, text: msg);
  }

  @override
  void dispose() {
    FirestoreManager
        .instance.subscriptions["OrdenDel${widget.pedido.numPedido}"]["id"]
        .cancel();
    super.dispose();
  }

  void checkOrder(Map<String, dynamic> content, String input) async {
    if (estado == "Entregando") {
      var dist = calculateDistance(latLines);
      if (dist < 0.01) {
        _showSnackBar("Pedido Completado!");

        await serv.putEstado2(
          "Completado",
          idPedido,
        );

        delayedPop(context);
      } else {
        _showSnackBar(
            "Debe estar a una distancia menor a 10 metros a la ubicación.");
      }
    } else {
      var dist = calculateDistance(latLines2);
      if (dist < 0.01) {
        /*log("${pedido.codigos?[0].toString()} $input");
        if (pedido.codigos?[0].toString() == input) {*/
        log("$dist / $idPedido");
        serv.putEstado2(
          "Entregando",
          idPedido, /*uidMot, pedido.comprador?.uid ?? ""*/
        );
        _showSnackBar("Vendedor alcanzado, entregue a Comprador.");
        estado = "Entregando";
        try {
          _polyline.removeAt(1);
          latLines[1] = LatLng(_position!.latitude, _position!.longitude);
        } catch (e) {
          log("polyline reset err: $e");
        }
      } else {
        _showSnackBar(
            "Debe estar a una distancia menor a 10 metros a la ubicación.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> content = json.decode(MainProvider.instance.data);

    isadmin = content["rol"] == "Administrador" ||
        content["rol"] == "Cliente" ||
        content["uid"] != pedido.motorizado!.uid;

    if (!_isLoading && motPos == null && isadmin && latLines2.isNotEmpty) {
      latLines2.clear();
    }

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
                    if (_position != null) {
                      if (renderTriggers[0] == 0) {
                        _latacunga = CameraPosition(
                          target: isadmin
                              ? motPos != null
                                  ? motPos!
                                  : latLines[1]
                              : LatLng(
                                  _position!.latitude, _position!.longitude),
                          zoom: 16,
                        );

                        updatePolylines();
                        _setMarker();
                      }
                    }

                    renderTriggers[0]++;
                    if (renderTriggers[0] > 10) {
                      renderTriggers[0] = 0;
                    }

                    return GoogleMap(
                      polylines: Set<Polyline>.of(_polyline),
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      markers: Set<Marker>.of(_markers),
                      mapType: MapType.normal,
                      initialCameraPosition: _latacunga,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    );
                  }),
                ),
                !isadmin
                    ? SlidingUpPanel(
                        minHeight: _collapsedHeight,
                        maxHeight: 310,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0),
                        ),
                        panel: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    constraints: const BoxConstraints(
                                        maxWidth:
                                            300), // Establece el ancho máximo
                                    child: const Text(
                                      'Para confirmar Retiros/Entregas, permanezca a una distancia del Vendedor/Comprador menor a 20 metros y después de retirar, presione "Llegué".',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      log("${_textController.text} ");
                                      checkOrder(content, _textController.text);
                                      _textController.clear();
                                    },
                                    child: const Text('Llegué'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      log("Cancelar Pedido");

                                      bool cancel = await showCustomDialog(
                                              context,
                                              options: const [
                                                "Alerta",
                                                "¿Está seguro de cancelar el pedido?",
                                                "Si",
                                                "No"
                                              ]) ??
                                          false;

                                      if (cancel) {
                                        _showSnackBar("Pedido Cancelado...");
                                        await serv.resetEstado(pedido);

                                        delayedPop(context);
                                      }
                                    },
                                    child: const Text('Cancelar Pedido'),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  height: 5.0,
                                  width: 50.0,
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        collapsed: const Center(
                          child: Text(
                            'Opciones',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 24.0,
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ]));
  }

  updatePolylines({bool force = false}) async {
    //Position? newpos = //await determinarPosicion();
    var newpos = getLocation();

    if (newpos.latitude != _position!.latitude ||
        newpos.longitude != _position!.longitude ||
        force) {
      _position = newpos;
      LatLng pos = isadmin && motPos != null
          ? motPos!
          : LatLng(_position!.latitude, _position!.longitude);

      if (estado == "Entregando") {
        latLines[1] = LatLng(pos.latitude, pos.longitude);
        _setPolyline(1, latLines, force: force);
      } else if (latLines2.length > 1) {
        //log("LEN:${latLines2.length}");

        latLines2[1] = LatLng(pos.latitude, pos.longitude);
        _setPolyline(1, latLines2, force: force);
      }
    }
  }

  Future<List<LatLng>> generateRoute(List<LatLng> latLinesAux) async {
    List<LatLng> polylineCoordinates = [];

    log("LIENS: $latLinesAux");

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyDxrtPdAdaFs06Q2P_ULt4pOB-Wms4n5gk",
        //"",
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

  Polyline genPolyline(List<LatLng> polylineCoordinates, int id, Color color) {
    return Polyline(
        polylineId: PolylineId("route$id"),
        width: 5,
        color: color,
        points: polylineCoordinates);
  }

  addRoute(List<LatLng> latLinesAux, int id,
      {Color color = Colors.black}) async {
    List<LatLng> polylineCoordinates = await generateRoute(latLinesAux);

    if (polylineCoordinates.isNotEmpty) {
      if (mounted) {
        setState(() {
          _polyline.add(genPolyline(polylineCoordinates, id, color));
        });
      }
    }
  }

  // Se necesita cuenta de pago para esto.
  setRoutes() async {
    log("setRoutes");
    //try {
    if (estado == "Entregando") {
      latLines[1] = LatLng(_position!.latitude, _position!.longitude);
      await addRoute(latLines, 0);
    } else {
      await addRoute(latLines, 0);
      await addRoute(latLines2, 1, color: CustomColors.secondaryColor);
    }

    if (_polyline.isEmpty) {
      log("Falló creando Rutas, usando Lineas Rectas...");
      usingRoutes = false;
      _obtenerlinea();
    }
  }

  _downloadAddres() async {
    log("downAddr()");

    var list = await FirestoreManager.instance
        .getData("OrdenDel", uid: widget.pedido.numPedido!);
    order = list.first;

    var com = order["ord_cliente"];
    var ven = order["ord_vendedor"];

    log("COMS: $com $ven");

    var latCom = com["datos"]["coords"]["lat"];
    var longCom = com["datos"]["coords"]["long"];

    var latVen = ven["datos"]["coords"]["lat"];
    var longVen = ven["datos"]["coords"]["long"];

    _markers.add(Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        markerId: const MarkerId('Comprador'),
        position: LatLng(double.parse(latCom), double.parse(longCom)),
        infoWindow: const InfoWindow(title: 'Comprador')));

    _markers.add(Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        markerId: const MarkerId('Vendedor'),
        position: LatLng(double.parse(latVen), double.parse(longVen)),
        infoWindow: const InfoWindow(title: 'Vendedor')));

    latLines2.add(
      LatLng(double.parse(latVen), double.parse(longVen)),
    );

    if (isadmin && order.containsKey("motorizado")) {

      var mot = order["motorizado"];
      var latMot = mot["datos"]["coords"]["lat"];
      var longMot = mot["datos"]["coords"]["long"];

      motPos = LatLng(double.parse(latMot), double.parse(longMot));

      final Uint8List markerIcon =
          await getBytesFromAsset('assets/images/bicicleta.png', 100);
      _markers.add(Marker(
          icon: BitmapDescriptor.fromBytes(markerIcon),
          markerId: const MarkerId('Motorizado'),
          position: motPos!,
          infoWindow: const InfoWindow(title: 'Motorizado')));

      latLines2.add(
        LatLng(motPos!.latitude, motPos!.longitude),
      );
    }

    latLines.add(
      LatLng(double.parse(latCom), double.parse(longCom)),
    );
    latLines.add(
      LatLng(double.parse(latVen), double.parse(longVen)),
    );
    if (_position != null && !isadmin) {
      latLines2.add(
        LatLng(_position!.latitude, _position!.longitude),
      );
    }
  }

  _obtenerPosicion() async {
    _position = getLocation(); //await determinarPosicion();

    if (_position != null) {
      _latacunga = CameraPosition(
        target: LatLng(_position!.latitude, _position!.longitude),
        zoom: 16,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  _obtenerlinea() async {
    if (estado == "Entregando") {
      latLines[1] = LatLng(_position!.latitude, _position!.longitude);

      _polyline.add(Polyline(
        polylineId: const PolylineId('route0'),
        points: latLines,
        color: Colors.green,
        width: 6,
      ));
    } else {
      _polyline.add(Polyline(
        polylineId: const PolylineId('route0'),
        points: latLines,
        color: Colors.green,
        width: 6,
      ));

      _polyline.add(Polyline(
        polylineId: const PolylineId('route1'),
        points: latLines2,
        color: Colors.orange,
        width: 6,
      ));
    }
  }

  _setPolyline(int id, List<LatLng> lines, {bool force = false}) async {
    try {
      log("_setPolyline $lines");

      if (usingRoutes) {
        List<LatLng> polylineCoordinates = await generateRoute(lines);
        _polyline[id] = genPolyline(polylineCoordinates, id, Colors.orange);
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

  _setMarker() async {
    renderTriggers[1]++;
    if (renderTriggers[1] > 100) {
      renderTriggers[1] = 0;

      var map = await FirestoreManager.instance
          .getData("OrdenDel", uid: widget.pedido.numPedido!);
      order = map.first;

      if (isadmin && order.containsKey("motorizado")) {
        LatLng oldMotPos = motPos!;

        log("SetMarker");

        var mot = order["motorizado"];
        var latMot = mot["datos"]["coords"]["lat"];
        var longMot = mot["datos"]["coords"]["long"];

        motPos = LatLng(double.parse(latMot), double.parse(longMot));

        if (oldMotPos.latitude != motPos!.latitude ||
            oldMotPos.longitude != motPos!.longitude) {
          final Uint8List markerIcon =
              await getBytesFromAsset('assets/images/bicicleta.png', 100);
          _markers[2] = Marker(
              icon: BitmapDescriptor.fromBytes(markerIcon),
              markerId: const MarkerId('Motorizado'),
              position: motPos!,
              infoWindow: const InfoWindow(title: 'Motorizado'));

          updatePolylines(force: true);
        }
      }
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
