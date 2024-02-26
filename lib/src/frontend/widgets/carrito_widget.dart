import 'dart:async';
//import 'dart:developer';

import 'package:flutter/material.dart';
//import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:prowes_motorizado/src/services/usuario_services.dart';
//import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:prowes_motorizado/src/backend/utils/distance.dart';
import 'package:prowes_motorizado/src/backend/utils/location.dart';
import 'package:prowes_motorizado/src/backend/utils/math.dart';
import 'package:prowes_motorizado/src/frontend/widgets/carrito_card_builder_widget.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
//import 'package:prowes_motorizado/src/models/producto_model.dart';
import 'dart:convert';
//import 'package:prowes_motorizado/src/services/pedidos_service.dart';
//import 'package:prowes_motorizado/src/frontend/pages/confirm_location_page.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
//import 'package:prowes_motorizado/src/provider/main_provider.dart';

class CarritoWidget extends StatefulWidget {
  const CarritoWidget({Key? key}) : super(key: key);

  @override
  State<CarritoWidget> createState() => _CarritoWidgetState();
}

class _CarritoWidgetState extends State<CarritoWidget> {
  late Timer _timer;
  double totalEnvio = 0;
  final mainProvider = MainProvider.instance;
  Map<String, dynamic> content = {};

  @override
  void initState() {
    super.initState();
    // Configura el temporizador para que se ejecute cada 30 segundos
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      var pos = getLocation(); //determinarPosicion();

      //Map<String, dynamic> content = json.decode(MainProvider.instance.data);

      //pos.then((value) {
      List<LatLng> polys = [
        LatLng(pos.latitude, pos.longitude),
        LatLng(-0.278533, -78.474069),
      ];
      totalEnvio = calculateDistance(polys) * 0.15;
      //});

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // Cancela el temporizador cuando el widget se desmonta
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //PedidoService _pedidoService = PedidoService();

    content = json.decode(mainProvider.data);

    double totalProd = 0;
    double total = 0;

    if (!content.containsKey("carrito")) {
      content["carrito"] = [];
    }

    for (var prod in content["carrito"]) {
      //log("$prod");

      totalProd += prod["total"];
    }

    total = totalProd + totalEnvio;

    return Stack(
      children: [
        Carrito(),
        SlidingUpPanel(
          minHeight: 75,
          maxHeight: 228,
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
                          maxWidth: 300), // Establece el ancho máximo
                      child: Text(
                        'Total Envio: >= ${Math.round(totalEnvio)}\$ (aprox)',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(
                          maxWidth: 300), // Establece el ancho máximo
                      child: Text(
                        '\nTotal Carrito: ${Math.round(totalProd)}\$',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20.0,
                        ),
                      ),
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
          collapsed: Center(
            child: Text(
              'Total: >= ${Math.round(total)}\$',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
