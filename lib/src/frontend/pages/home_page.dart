import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';
import 'package:prowes_motorizado/src/backend/models/pedido_model.dart';
import 'package:prowes_motorizado/src/backend/services/pedidos_service.dart';
import 'package:prowes_motorizado/src/backend/utils/location.dart';
import 'package:prowes_motorizado/src/backend/utils/math.dart';
import 'package:prowes_motorizado/src/frontend/pages/page_builder.dart';
import 'package:prowes_motorizado/src/frontend/widgets/custom_popup_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/delivery_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/detalle_pedido_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/perfil_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/opciones_widget.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:prowes_motorizado/src/backend/services/usuario_services.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
//import 'package:prowes_motorizado/src/firestore/firestore_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController = PageController();
  int selectedIndex = 1;
  late Timer _timer;
  UsuarioService serv = UsuarioService();
  List<CustomPopupNotification> _notifications = [];
  List<String> uids = [];
  final PedidoService _pedidoService = PedidoService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedIndex);

    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      MainProvider mainProvider = MainProvider.instance;

      var pos = getLocation(); //determinarPosicion();
      Future.delayed(const Duration(seconds: 7), () {
        if (mounted) {
          Map<String, dynamic> content = json.decode(mainProvider.data);
          serv.updateLocation(
              content["uid"], LatLng(pos.latitude, pos.longitude));
          setState(() {});
        }
      });
    });

    FirestoreManager.instance.subscribe(
      "OrdenDel",
      customId: "notfs",
      callback: () {
        //var posf = determinarPosicion();
        //posf.then((pos) {

        var content = json.decode(MainProvider.instance.data);
        var fut = _pedidoService.getPedido(uid1: content["uid"]);

        fut.then((value) {
          bool empty = false;

          if (uids.isEmpty) {
            empty = true;
          }

          for (var p in value) {
            var uid = p.numPedido;

            if (!uids.contains(uid)) {
              uids.add(uid.toString());
              if (!empty) {
                addNotification(
                    "Tiene un nuevo pedido!\nAprox Envio: ${Math.round(p.distance! * 0.15)}\$\nProductos: ${p.productos!.length}",
                    p);
              }
            }
          }
        });
        //});
      },
    );
  }

  void addNotification(String msg, Pedido pedido) {
    //log("LEN: ${_notifications.length}");

    setState(() {
      // Agrega una nueva notificación al mapa con un identificador único
      _notifications.add(CustomPopupNotification(
        message: msg,
        onAccept: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  PageBuilder(bodyWidget: DetallePedido(pedido: pedido)),
            ),
          );
        },
        onDismissed: () {},
        options: ["Detalles", "Rechazar"],
      ));
    });
  }

  void onButtonPressed(int index) {
    if (mounted) {
      setState(() => selectedIndex = index);
    }
    _pageController.animateToPage(selectedIndex,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOutQuad);
  }

  @override
  void dispose() {
    _timer.cancel();
    FirestoreManager.instance.subscriptions["OrdenDelnotfs"]["id"].cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CustomColors.primaryColor, //
              CustomColors.primaryColor, //
              CustomColors.primaryColor, //
            ],
          )),
        ),
        toolbarHeight: 50.h,
        centerTitle: true,
        elevation: 10.h,
        title: Stack(
          alignment: Alignment.topRight,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20.h),
                  child: Image.asset(
                    'assets/images/Logo_2.png',
                    fit: BoxFit.contain,
                    height: 100.h,
                    width: 100.h,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: _listOfWidget,
            ),
          ),
          Positioned.fill(
            child: Stack(
              children: _notifications.toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SlidingClippedNavBar(
        backgroundColor: CustomColors.primaryColor,
        onButtonPressed: onButtonPressed,
        iconSize: 32.h,
        activeColor: Colors.black,
        selectedIndex: selectedIndex,
        barItems: <BarItem>[
          BarItem(icon: Icons.person_outline, title: 'Perfil'),
          BarItem(icon: Icons.local_shipping, title: 'Pedidos'),
          BarItem(icon: Icons.contact_mail, title: 'Contacto'),
        ],
      ),
    );
  }
}

List<Widget> _listOfWidget = <Widget>[
  const PerfilWidget(),
  const DeliveryWidget(),
  const OpcionesWidget(),
];
