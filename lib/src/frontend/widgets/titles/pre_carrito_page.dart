import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:prowes_motorizado/src/backend/utils/distance.dart';
import 'package:prowes_motorizado/src/backend/utils/location.dart';
import 'package:prowes_motorizado/src/frontend/widgets/carrito_card_builder_widget.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'dart:convert';
import 'package:prowes_motorizado/src/frontend/pages/confirm_location_page.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PreCarritoPage extends StatefulWidget {
  const PreCarritoPage({Key? key}) : super(key: key);

  @override
  State<PreCarritoPage> createState() => _PreCarritoPageState();
}

class _PreCarritoPageState extends State<PreCarritoPage> {
  late Timer _timer;
  double totalEnvio = 0;

  @override
  void initState() {
    super.initState();
    // Configura el temporizador para que se ejecute cada 30 segundos
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      var pos = determinarPosicion();
      
      //Map<String, dynamic> content = json.decode(MainProvider.instance.data);

      pos.then((value) {
        List<LatLng> polys = [
          LatLng(value.latitude, value.longitude),
          LatLng(-0.278533, -78.474069),
        ];
        totalEnvio = calculateDistance(polys);
      });

      if (mounted) {
        setState(() {
          
        });
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

    final mainProvider = MainProvider.instance; 
    Map<String, dynamic> content = json.decode(mainProvider.data);
    double totalProd = 0;
    double total = 0;

    if (!content.containsKey("carrito")){
      content["carrito"] = [];
    }

    for (var prod in content["carrito"]) {
      //log("$prod");

      totalProd += prod["pro_total"];
    }

    total = totalProd + totalEnvio;

    return Scaffold(
        appBar: AppBar(
          elevation: 10,
          leading: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            iconSize: 20,
            tooltip: 'Regresar',
            color: Colors.black,
            onPressed: () => Navigator.of(context).pop(),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CustomColors.primaryColor,
                  CustomColors.primaryColor,
                  CustomColors.primaryColor,
                ],
              ),
            ),
          ),
          toolbarHeight: 85,
          centerTitle: true,
          title: Row(children: [
            Spacer(),
            Image.asset(
              'assets/images/Logo_2.png',
              alignment: Alignment.centerRight,
              fit: BoxFit.contain,
              height: 150,
              width: 150,
            ),
            Spacer(),
            Stack(
              alignment: Alignment.topRight,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0.0, right: 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomColors.secondaryColor,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30.0,
                      ),
                      onPressed: () async {

                        String msg = "Elija la ubicación exacta de retiro.";

                        if (!content.containsKey("carrito")) {
                          content["carrito"] = [];
                        }

                        if (content["carrito"].length > 0) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MapPage()));
                        } else {
                          msg = "No hay productos en el carrito.";
                          Navigator.of(context).pop();
                        }

                        var snackBar = SnackBar(
                          content: Text(
                            msg,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          duration: Duration(seconds: 10),
                        );

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
        body: Stack(
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
                            'Total envio: $totalEnvio\$',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 24.0,
                            ),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(
                              maxWidth: 300), // Establece el ancho máximo
                          child: Text(
                            '\nTotal productos: $totalProd\$',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 24.0,
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
                  'Total: $total\$',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 24.0,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
