import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';
import 'package:prowes_motorizado/src/backend/models/pedido_model.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'package:prowes_motorizado/src/backend/services/pedidos_service.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:prowes_motorizado/src/backend/utils/location.dart';
import 'package:prowes_motorizado/src/frontend/pages/all_orders_page.dart';
import 'package:prowes_motorizado/src/frontend/widgets/custom_popup_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/dellivery_card_widget.dart';
import 'dart:developer';

import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';
//import 'dart:convert';

class DeliveryWidget extends StatefulWidget {
  const DeliveryWidget({Key? key}) : super(key: key);

  @override
  State<DeliveryWidget> createState() => _DeliveryWidgetState();
}

class _DeliveryWidgetState extends State<DeliveryWidget> {
  final PedidoService _pedidoService = PedidoService();
  late Future<List<Pedido>> _pedidosFuture;

  @override
  void initState() {
    super.initState();
    _pedidosFuture = _downloadPedido();

    FirestoreManager.instance.subscribe(
      "OrdenDel",
      callback: () {
          var content = json.decode(MainProvider.instance.data);
          var fut = _pedidoService.getPedido(uid1: content["uid"]);

          fut.then((value) {
            if (mounted) {
              setState(() {
                _pedidosFuture = fut;
              });
            }
          });
      },
    );
  }

  @override
  void dispose() {
    FirestoreManager.instance.subscriptions["OrdenDel"]["id"].cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("DeliveryCardWidget()");

    return SafeArea(
      
      child: RefreshIndicator(
        onRefresh: () async {
          _updatePedido();
        },
        child: Column(
        children: [
          GestureDetector(
                              onTap: () {
                                Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => AllOrders(),
          ),
        );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 25.h, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: CustomColors.secondaryColor,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Centra los elementos del Row
                                  children: [
                                    Text(
                                      "Ver Pedidos Aceptados ",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.h,
                                      ),
                                    ),
                                    Icon(
                                      Icons.map,
                                      color: Colors.white,
                                      size: 25.h,
                                    ),
                                  ],
                                ),
                              ),
                            ),
          Padding(
            padding: EdgeInsets.only(top: 10.h, left: 50.h, right: 50.h),
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
                          child:
                              Image.asset('assets/images/delivery-truck.png')),
                      SizedBox(width: 15.h),
                      Text(
                        "Pedidos",
                        style: TextStyle(
                            fontSize: 18.h, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
         
          Expanded(
            child: FutureBuilder<List<Pedido>>(
              future: _pedidosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("De momento no hay Pedidos Disponibles..."));
                } else if (snapshot.hasData) {
                  return _buildPedidosList(snapshot.data!);
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
      ],
      ), ),
    );
  }

  Future<List<Pedido>> _downloadPedido() async {
    var content = json.decode(MainProvider.instance.data);

    ///log("${content["uid"]}");
    final pedidos = await _pedidoService.getPedido(uid1: content["uid"]);
    return pedidos;
  }

  Future<void> _updatePedido() async {
    _pedidosFuture = _downloadPedido();
    //MainProvider.instance.updateOrder();
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildPedidosList(List<Pedido> pedidos) {
    final pedidosPorEstado = groupPedidosPorEstado(pedidos);

    return ListView(
      children: pedidosPorEstado.entries
          .map((entry) => _buildPedidosPorEstado(entry.key, entry.value))
          .toList(),
    );
  }

  Widget _buildPedidosPorEstado(String estado, List<Pedido> pedidos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.h, left: 50.h, right: 50.h),
          child: Text(
            estado,
            style: TextStyle(
              fontSize: 18.h,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Column(
          children: pedidos
              .map((pedido) => DeliveryCardWidget(
                    pedido: pedido,
                    onDataUpdated: () async {
                      log("onDataUpdated DeliveryWidget");
                      _updatePedido();
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Map<String, List<Pedido>> groupPedidosPorEstado(List<Pedido> pedidos) {
    final Map<String, List<Pedido>> pedidosPorEstado = {};

    for (final pedido in pedidos) {
      final estado = pedido.estado;
      if (!pedidosPorEstado.containsKey(estado)) {
        pedidosPorEstado[estado!] = [];
      }
      pedidosPorEstado[estado]!.add(pedido);
    }

    return pedidosPorEstado;
  }
}
