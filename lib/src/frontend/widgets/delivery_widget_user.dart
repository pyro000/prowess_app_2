import 'package:flutter/material.dart';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';
//import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'package:prowes_motorizado/src/models/pedido_model.dart';
import 'package:prowes_motorizado/src/backend/models/producto_model.dart';
//import 'package:prowes_motorizado/src/provider/main_provider.dart';
import 'package:prowes_motorizado/src/backend/services/productos_service.dart';
import 'package:prowes_motorizado/src/frontend/widgets/dellivery_card_widget_user.dart';
import 'dart:developer';

import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';
//import 'dart:convert';

class DeliveryWidgetUser extends StatefulWidget {
  const DeliveryWidgetUser({Key? key}) : super(key: key);

  @override
  State<DeliveryWidgetUser> createState() => _DeliveryWidgetState();
}

class _DeliveryWidgetState extends State<DeliveryWidgetUser> {
  final ProductoService _productoService = ProductoService();
  late Future<List<Producto>> _productosFuture;
  late Future<List<Map<String, dynamic>>> _categoriasFuture;

  @override
  void initState() {
    super.initState();
    _productosFuture = _downloadProductos();
    _categoriasFuture = _downloadCategorias();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          _updateProductos();
        },
        child: FutureBuilder<List<Producto>>(
          future: _productosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No hay productos disponibles"),
              );
            } else if (snapshot.hasData) {
              return _buildProductosList(snapshot.data!);
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }

  Widget _buildProductosList(List<Producto> productos) {
    final Map<String, List<Producto>> productosPorCategoria =
        groupProductosPorCategoria(productos);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.0, top: 16.0),
          child: Row(
            children: [
              Image.asset(
                'assets/images/almuerzo.png',
                height: 24.0,
                width: 24.0,
              ),
              SizedBox(width: 8.0),
              Text(
                'Menú',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: productosPorCategoria.length,
            itemBuilder: (context, index) {
              final categoria = productosPorCategoria.keys.elementAt(index);
              final productosEnCategoria = productosPorCategoria[categoria]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(top: 20.0, left: 50.0, right: 50.0),
                    child: Material(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16.0),
                      child: SizedBox(
                        height: 50.0,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                categoria,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: productosEnCategoria
                        .map((producto) => DeliveryCardWidget(
                              producto: producto,
                              onDataUpdated: () async {
                                log("onDataUpdated DeliveryWidget");
                                _updateProductos();
                              },
                            ))
                        .toList(),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<Producto>> _downloadProductos() async {
    final productos = await _productoService.getProductos();
    return productos ?? [];
  }

  Future<List<Map<String, dynamic>>> _downloadCategorias() async {
    var map = FirestoreManager.instance.getData("CategoriasDel");
    return map;
  }

  void _updateProductos() {
    setState(() {
      _productosFuture = _downloadProductos();
      _categoriasFuture = _downloadCategorias();
    });
  }

  Map<String, List<Producto>> groupProductosPorCategoria(
      List<Producto> productos) {
    Map<String, List<Producto>> productosPorCategoria = {};

    for (final producto in productos) {
      final categoria = producto.categoria;
      if (!productosPorCategoria.containsKey(categoria)) {
        productosPorCategoria[categoria!] = [];
      }
      productosPorCategoria[categoria]!.add(producto);
    }

    productosPorCategoria = ordenarMapa(productosPorCategoria);
    return productosPorCategoria;
  }

  Map<String, List<Producto>> ordenarMapa(Map<String, List<Producto>> mapa) {
    List<String> categorias = mapa.keys.toList();

    categorias.sort((a, b) => b.compareTo(a));

    Map<String, List<Producto>> mapaOrdenado = {};
    categorias.forEach((categoria) {
      mapaOrdenado[categoria] = mapa[categoria]!;
    });

    return mapaOrdenado;
  }
}
