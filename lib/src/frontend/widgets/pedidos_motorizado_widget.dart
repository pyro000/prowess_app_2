import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';
import 'package:prowes_motorizado/src/backend/models/pedido_model.dart';
import 'package:prowes_motorizado/src/backend/services/pedidos_service.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:prowes_motorizado/src/backend/utils/math.dart';
import 'package:prowes_motorizado/src/frontend/pages/page_builder.dart';
import 'package:prowes_motorizado/src/frontend/widgets/custom_popup_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/detalle_pedido_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/pedidos_motorizado_card_widget.dart';
import 'dart:developer';

class PedidoMotorizado extends StatefulWidget {
  const PedidoMotorizado({Key? key, required this.uid}) : super(key: key);
  final String uid;

  @override
  State<PedidoMotorizado> createState() => _PedidoMotorizadoState();
}

class _PedidoMotorizadoState extends State<PedidoMotorizado> {
  final PedidoService _pedidoService = PedidoService();
  late Future<List<Pedido>>? _pedidosFuture;
  late String uid;
  List<CustomPopupNotification> _notifications = [];
  List<String> uids = [];

  @override
  void initState() {
    super.initState();
    _pedidosFuture = _downloadPedido();
    uid = widget.uid;

    FirestoreManager.instance.subscribe(
      "OrdenDel", 
      customId: "notfs",
      callback: () {
        //var posf = determinarPosicion();
        //posf.then((pos) {
          var fut = _pedidoService.getPedido();

          fut.then((value) {
            _pedidosFuture = fut;

            bool empty = false;

            if (uids.isEmpty) {
              empty = true;
            }
            
            for (var p in value)  {
              var uid = p.numPedido;

              if (!uids.contains(uid)) {
                uids.add(uid.toString());
                if (!empty) {
                  addNotification("Tiene un nuevo pedido!\nAprox Envio: ${Math.round(p.distance!*0.15)}\$\nProductos: ${p.productos!.length}", p);
                }
              }
            }
          });
        //});
      },
    );
  }

  @override
  void dispose() {
    FirestoreManager.instance.subscriptions["OrdenDelnotfs"]["id"].cancel();
    super.dispose();
  }

  void addNotification(String msg, Pedido pedido) {
    log("LEN: ${_notifications.length}");

    setState(() {
      // Agrega una nueva notificación al mapa con un identificador único
      _notifications.add(CustomPopupNotification(
        message: msg,
        onAccept: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                PageBuilder(bodyWidget: DetallePedido(pedido: pedido)) ,
            ),
          );
        },
        onDismissed: () {
        },
        options: ["Detalles", "Rechazar"],
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    log("PedidoMotorizado()");

    return 
      Stack(
        children: [
    SafeArea(
            child:
    Container(
      margin: EdgeInsets.symmetric(vertical: 3.h),
      child: FutureBuilder<List<Pedido>>(
        future: _pedidosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("No tiene Pedidos"));
          } else if (snapshot.hasData) {
            // Ordenar los pedidos por su estado
            final List<Pedido> pedidos = snapshot.data!;
            pedidos.sort((a, b) => a.estado!.compareTo(b.estado!));

            return ListView.builder(
              itemCount: pedidos.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final pedido = pedidos[index];

                // Agregar texto arriba del primer elemento de cada categoría
                if (index == 0 ||
                    pedido.estado != pedidos[index - 1].estado) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.h), // Espacio entre categorías
                      Padding(
                        padding: EdgeInsets.only(left: 10.h), // Ajusta la cantidad de espacio a la derecha
                        child: Text(
                          pedido.estado!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.h,
                            //color: Colors.blue, // Color de texto de la categoría
                          ),
                        ),
                      ),
                      PedidoCardMotorizado(
                        pedido: pedido,
                        onDataUpdated: () {
                          log("onDataUpdated PedidoMotorizado");
                          _updatePedido();
                        },
                        uid: uid,
                      ),
                    ],
                  );
                } else {
                  return PedidoCardMotorizado(
                    pedido: pedido,
                    onDataUpdated: () {
                      log("onDataUpdated PedidoMotorizado");
                      _updatePedido();
                    },
                    uid: uid,
                  );
                }
              },
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    )),

    Positioned.fill(
            child: Stack(
              children: _notifications.toList(),
            ),
          ),
    
    ]);
  }

  Future<List<Pedido>> _downloadPedido() async {
    log("DownloadPedido");
    var pedidos =
        await _pedidoService.getPedido();//(uid1: widget.uid, prior: true);
    return pedidos ?? [];
  }

  Future<void> _updatePedido() async {
    _pedidosFuture = _downloadPedido();
    //MainProvider.instance.updateOrder();
    if (mounted) {
      setState(() {});
    }
  }
}
