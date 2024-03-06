import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prowes_motorizado/src/backend/models/producto_model.dart';
//import 'package:prowes_motorizado/src/firestore/firestore_manager.dart';
//import 'package:prowes_motorizado/src/pages/home_client_page.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:prowes_motorizado/src/backend/services/pedidos_service.dart';
import 'package:prowes_motorizado/src/backend/services/usuario_services.dart';
import 'package:prowes_motorizado/src/frontend/pages/loading_window.dart';
import 'package:prowes_motorizado/src/backend/utils/snack_bar.dart';
import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng _currentLocation = LatLng(0.0, 0.0);
  LatLng _centerMarkerLocation = LatLng(0.0, 0.0);
  bool _isLoading = true;
  PedidoService _pedidoService = PedidoService();
  UsuarioService _usuarioService = UsuarioService();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _centerMarkerLocation = _currentLocation;
      });
      _moveToCurrentLocation();
      _isLoading = false;
    } catch (e) {
      print('Error al obtener la ubicación: $e');
    }
  }

  void _moveToCurrentLocation() async {
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation, 25));
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onCameraMove(CameraPosition position) {
    // Actualizar la posición del marcador central
    setState(() {
      _centerMarkerLocation = position.target;
    });
  }

  void _onCenterLocation() {
    _moveToCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10.h,
        leading: IconButton(
            padding: EdgeInsets.symmetric(horizontal: 0.h),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            iconSize: 20.h,
            tooltip: 'Regresar',
            color: Colors.black,
            onPressed: () {
              delayedPop(context);
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
        title: Row(children: [
          Spacer(),
          Image.asset(
            'assets/images/Logo_2.1.png',
            alignment: Alignment.centerRight,
            fit: BoxFit.contain,
            height: 100.h,
            width: 100.h,
          ),
          Spacer(),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(CustomColors.textColor),
                ))
              : Stack(
                  alignment: Alignment.topRight,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        _isLoading = true;

                        final mainProvider = MainProvider.instance;
                        Map<String, dynamic> content =
                            json.decode(mainProvider.data);

                        List<Map<String, dynamic>> result = [];

                        for (var p in content["carrito"]) {
                          Producto prod = Producto.fromJson2(p);
                          result.add(prod.toJson2());
                        }

                        log("updating loc");
                        await _usuarioService.updateLocation(
                            content["uid"], _centerMarkerLocation);

                        log("publishing");

                        var uid = await _pedidoService.newPedido(
                            result, content["uid"]);

                        log("New pedido: $uid");

                        content["carrito"] = [];
                        mainProvider.data = json.encode(content);

                        SnackBarTool.showSnackbar(context,
                            text: 'Pedido Creado.');
                        delayedPop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5.0),
                        margin: EdgeInsets.symmetric(
                            horizontal: 0.h, vertical: 0.h),
                        decoration: BoxDecoration(
                          color: CustomColors.secondaryColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Confirmar ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.h,
                              ),
                            ),
                            Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 15.h,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ]),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 25.0,
              ),
              onCameraMove: _onCameraMove,
              markers: {
                Marker(
                  markerId: MarkerId('centerMarker'),
                  position: _centerMarkerLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange),
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCenterLocation,
        child: Icon(Icons.my_location),
        backgroundColor: CustomColors.secondaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .startFloat, // Cambiado a la esquina inferior izquierda
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MapPage(),
  ));
}
