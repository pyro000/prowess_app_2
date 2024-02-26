import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';
import 'package:prowes_motorizado/src/backend/models/pedido_model.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'package:prowes_motorizado/src/backend/services/pedidos_service.dart';
import 'package:prowes_motorizado/src/backend/utils/location.dart';
import 'package:prowes_motorizado/src/frontend/widgets/dellivery_card_widget.dart';
//import 'package:prowes_motorizado/src/pages/detalle_pedido_user.dart';
import 'dart:developer';
import 'dart:convert';

import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';

class DetailsUser extends StatefulWidget {
  const DetailsUser({Key? key}) : super(key: key);

  @override
  State<DetailsUser> createState() => _DeliveryWidgetState();
}

class _DeliveryWidgetState extends State<DetailsUser> {
  final PedidoService _pedidoService = PedidoService();
  late Future<List<Pedido>> _pedidosFuture;

  @override
  void initState() {
    super.initState();
    log("CACA");
    _pedidosFuture = _downloadPedido();

    FirestoreManager.instance.subscribe(
      "OrdenDel",
      callback: () {
        var content = json.decode(MainProvider.instance.data);

        var fut = _pedidoService.getPedido(
          uid1: content["uid"],
          prior: true,
          client: true,
        );

        fut.then((value) {
          _pedidosFuture.then((value1) {
            if (mounted) {
              if (!listasPedidosSonIguales(value, value1)) {
                setState(() {
                  _pedidosFuture = fut;
                });
              }
            }
          });
        });
        //});
      },
    );
  }

  bool listasPedidosSonIguales(List<Pedido> lista1, List<Pedido> lista2) {
    if (lista1.length != lista2.length) return false;
    for (int i = 0; i < lista1.length; i++) {
      if (lista1[i] != lista2[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    try {
      FirestoreManager.instance.subscriptions["OrdenDel"]["id"].cancel();
    } catch (e) {
      print('Error al cancelar la suscripción: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("DeliveryCardWidget()");

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20.h, left: 50.h, right: 50.h),
            child: Material(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16.h),
              child: SizedBox(
                height: 50.h,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 40.h,
                        width: 40.h,
                        child: Image.asset('assets/images/delivery-truck.png'),
                      ),
                      SizedBox(width: 15.h),
                      Text(
                        "Pedidos",
                        style: TextStyle(
                          fontSize: 18.h,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Pedido>>(
              future: _pedidosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: LoadingIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("No tiene pedidos agregados."));
                } else if (snapshot.hasData) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      _updatePedido();
                    },
                    child: ListView(
                      children: snapshot.data!
                          .map((e) => DeliveryCardWidget(
                                pedido: e,
                                onDataUpdated: () async {
                                  log("onDataUpdated DeliveryWidget");
                                  _updatePedido();
                                },
                              ))
                          .toList(),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Pedido>> _downloadPedido() async {
    var data = json.decode(MainProvider.instance.data);
    final pedidos = await _pedidoService.getPedido(
      uid1: data["uid"],
      prior: true,
      client: true,
    );
    return pedidos;
  }

  Future<void> _updatePedido() async {
    _pedidosFuture = _downloadPedido();
    //MainProvider.instance.updateOrder();
    if (mounted) {
      setState(() {});
    }
  }
}
