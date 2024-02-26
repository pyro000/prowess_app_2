import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/models/producto_model.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:prowes_motorizado/src/backend/utils/math.dart';
import 'package:prowes_motorizado/src/backend/utils/snack_bar.dart';
import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/scrollable_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'dart:developer';

class DetalleUserPedido extends StatefulWidget {
  const DetalleUserPedido({Key? key, required this.producto}) : super(key: key);
  final Producto producto;

  @override
  State<DetalleUserPedido> createState() => _DetallePedidoState();
}

class _DetallePedidoState extends State<DetalleUserPedido> {
  bool rendered = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var prod = widget.producto;
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20.h, left: 40.h, right: 40.h),
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
                        height: 30.h,
                        width: 30.h,
                        child: Image.asset('assets/images/delivery-truck.png'),
                      ),
                      SizedBox(width: 10.h),
                      Expanded(
                        // Usa Expanded alrededor del Text
                        child: Text(
                          "Detalles de Producto",
                          style: TextStyle(
                            fontSize: 20.h,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 15.h,
            width: 15.h,
          ),
          Card(
              elevation: 3,
              child: Column(
                children: [
                  ListTile(
                    title: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: CustomColors.primaryColor,
                              radius: 45.h,
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  width: 114.h,
                                  height: 114.h,
                                  fit: BoxFit.cover,
                                  imageUrl: prod.imagen ?? "",
                                  placeholder: (context, url) =>
                                      const LoadingIndicator(
                                    color: Colors.black,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.person),
                                ),
                              ),
                            ),
                            Flexible(
                              child: ScrollableWidget(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(10.h, 0, 0, 0),
                                      child: Text('Nombre: ${prod.nombre}'),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(10.h, 0, 0, 0),
                                      child: Text('Precio: ${Math.round(prod.precio!)}\$'),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(10.h, 0, 0, 0),
                                      child: Text('Disponible: ${prod.stock}'),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          GestureDetector(
            onTap: () {
              agregarCarrito(prod);
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: EdgeInsets.symmetric(horizontal: 50.h, vertical: 5.h),
              decoration: BoxDecoration(
                color: CustomColors.secondaryColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Agregar al Carrito ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.h,
                    ),
                  ),
                  Icon(
                    Icons.shopping_cart_checkout,
                    color: Colors.white,
                    size: 25.h,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void agregarCarrito(Producto prod) {
    final mainProvider = MainProvider.instance;
    Map<String, dynamic> content = json.decode(mainProvider.data);

    SnackBarTool.showSnackbar(context, text: "Agregado al carrito.");
    if (!content.containsKey("carrito")) {
      content["carrito"] = [];
    }
    prod.id = content["carrito"].length;
    content["carrito"].add(prod.toJson());
    mainProvider.data = json.encode(content);
    Navigator.of(context).pop();
  }
}
