import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';
import 'package:prowes_motorizado/src/backend/models/producto_model.dart';
import 'package:prowes_motorizado/src/backend/services/launch_services.dart';
import 'package:prowes_motorizado/src/backend/models/comprador_model.dart';
import 'package:prowes_motorizado/src/backend/models/usuario_model.dart';
//import 'package:prowes_motorizado/src/models/detalle_model.dart';
import 'package:prowes_motorizado/src/backend/models/pedido_model.dart';
import 'package:prowes_motorizado/src/backend/models/vendedor_model.dart';
import 'package:prowes_motorizado/src/backend/utils/custom_dialog.dart';
import 'package:prowes_motorizado/src/backend/utils/math.dart';
import 'package:prowes_motorizado/src/frontend/pages/location_page.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'package:prowes_motorizado/src/backend/services/pedidos_service.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:prowes_motorizado/src/backend/utils/snack_bar.dart';
import 'package:prowes_motorizado/src/frontend/widgets/distancia_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/scrollable_widget.dart';

import 'dart:convert';
import 'dart:developer';

class DetallePedido extends StatefulWidget {
  const DetallePedido({Key? key, required this.pedido}) : super(key: key);
  final Pedido pedido;

  @override
  State<DetallePedido> createState() => _DetallePedidoState();
}

class _DetallePedidoState extends State<DetallePedido> {
  final PedidoService _pedidoService = PedidoService();
  late Future<Pedido?> pedido;
  late String numPedido;
  bool _showButton = false;
  bool rendered = false;

  final mainProvider = MainProvider.instance;
  Map<String, dynamic> content = {};

  @override
  void initState() {
    super.initState();
    numPedido = widget.pedido.numPedido.toString();
    pedido = _downloadPedido();

    FirestoreManager.instance.subscribe(
      "OrdenDel",
      uid: numPedido,
      callback: () {
        pedido = _downloadPedido();
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    FirestoreManager.instance.subscriptions["OrdenDel$numPedido"]["id"]!
        .cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Pedido?>(
      future: pedido,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator(
            key: widget.key,
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final pedido = snapshot.data!;
          List<Producto> detalle = pedido.productos!.toList();
          Vendedor? vendedor = pedido.vendedor;
          Comprador? comprador = pedido.comprador;
          Usuario? motorizado = pedido.motorizado;

          var status = pedido.estado;
          var rol = content["rol"];

          _showButton = (status != "Procesando" &&
              status != "Completado" &&
              status != "Entregando" &&
              rol != "Administrador" &&
              rol != "Cliente");

          // Resto del código con el pedido ya disponible
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.only(top: 20.h /*, left: 80.h, right: 80.h*/),
                  child: Material(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16.h),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10.h),
                          child: Image.asset(
                            'assets/images/delivery-truck.png',
                            height: 30.h,
                            width: 30.h,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.h, horizontal: 10.h),
                          child: Text(
                            "Detalles de Pedido",
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
                SizedBox(
                  height: 15.h,
                  width: 15.h,
                ),
                Divider(
                        height: 8.h,
                        endIndent: 5.h,
                        indent: 5.h,
                        color: Colors.black,
                        thickness: 1.h,
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                Card(
                  elevation: 3,
                  child: Column(
                    children: [
                      ListTile(
                        title: Column(
                          children: [
                            Container(
                              width: 700.0,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 40.h,
                                      width: 60.h,
                                      child: Image.asset(
                                          'assets/images/vendedor.png'),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Row(
                                          children: const [
                                            Text(
                                              'Vendedor',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10.h, 0, 0, 0),
                                          child: Text('Nombre: ' +
                                              vendedor!.nombre.toString()),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10.h, 0, 0, 0),
                                          child: Text('Telefono: ' +
                                              vendedor.phone.toString()),
                                        ),
                                        /*Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(10.h, 0, 0, 0),
                                      child: Text('Ciudad: ' +
                                          vendedor.),
                                    ),*/
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10.h, 0, 0, 0),
                                          child: Text('Sector: ' +
                                              vendedor.calle.toString()),
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        Container( 
                                            width: 250,
                                            child:
                                          Row(
                                            children: [
                                              Image(
                                                  alignment: Alignment.center,
                                                  image: const AssetImage(
                                                      'assets/images/whatsapp.png'),
                                                  width: 20.h,
                                                  ),
                                              SizedBox(width: 8.h),
                                              buildRaisedButton(
                                                  "WhatsApp",
                                                  () => launchURL(vendedor
                                                      .phone
                                                      .toString()) // Envuelve la llamada a launchURL en una función anónima
                                                  ),
                                              SizedBox(width: 10.h),
                                              Image(
                                                  alignment: Alignment.center,
                                                  image: const AssetImage(
                                                      'assets/images/llamadaentrante.png'),
                                                  width: 17.h),
                                              SizedBox(width: 8.h),
                                              buildRaisedButton(
                                                  "Llamar",
                                                  () => launchPhone(vendedor
                                                      .phone
                                                      .toString())),
                                            ],
                                          )),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 8.h,
                              color: Colors.black,
                              thickness: 1.h,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Container(
                              width: 700.0,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 40.h,
                                      width: 60.h,
                                      child: Image.asset(
                                          'assets/images/comprador.png'),
                                    ),
                                    ScrollableWidget(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Row(

        children: const [
                                              Text(
                                                'Comprador',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10.h, 0, 0, 0),
                                            child: Text('Nombre: ' +
                                                comprador!.nombre.toString()),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10.h, 0, 0, 0),
                                            child: Text('Telefono: ' +
                                                comprador.phone.toString()),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10.h, 0, 0, 0),
                                            child: Text('Sector: ' +
                                                comprador.dir.toString()),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          
                                          Container( 
                                            width: 250,
                                            child:
                                          Row(
                                            children: [
                                              Image(
                                                  alignment: Alignment.center,
                                                  image: const AssetImage(
                                                      'assets/images/whatsapp.png'),
                                                  width: 20.h,
                                                  ),
                                              SizedBox(width: 8.h),
                                              buildRaisedButton(
                                                  "WhatsApp",
                                                  () => launchURL(comprador
                                                      .phone
                                                      .toString()) // Envuelve la llamada a launchURL en una función anónima
                                                  ),
                                              SizedBox(width: 10.h),
                                              Image(
                                                  alignment: Alignment.center,
                                                  image: const AssetImage(
                                                      'assets/images/llamadaentrante.png'),
                                                  width: 17.h),
                                              SizedBox(width: 8.h),
                                              buildRaisedButton(
                                                  "Llamar",
                                                  () => launchPhone(comprador
                                                      .phone
                                                      .toString())),
                                            ],
                                          )),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            motorizado!.name!.isNotEmpty
                                ? Divider(
                              height: 8.h,
                              color: Colors.black,
                              thickness: 1.h,
                            ) : Container(),

                             SizedBox(
                                        height: 10.h,
                                      ),
                            
                            motorizado.name!.isNotEmpty
                                ? Row(
                                    children: [
                                     
                                      SizedBox(
                                        height: 40.h,
                                        width: 60.h,
                                        child: Image.asset(
                                            'assets/images/bicicleta.png'),
                                      ),
                                      ScrollableWidget(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Row(
                                              children: const [
                                                Text(
                                                  'Motorizado',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10.h, 0, 0, 0),
                                              child: Text('Nombre: ' +
                                                  motorizado.name.toString()),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10.h, 0, 0, 0),
                                              child: Text('Telefono: ' +
                                                  motorizado.telefono
                                                      .toString()),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10.h, 0, 0, 0),
                                              child: Text('Placa: ' +
                                                  motorizado.numPlaca
                                                      .toString()),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10.h, 0, 0, 0),
                                              child: Text('Color: ' +
                                                  motorizado.colorVeh
                                                      .toString()),
                                            ),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            Container( 
                                            width: 250,
                                            child:
                                          Row(
                                            children: [
                                              Image(
                                                  alignment: Alignment.center,
                                                  image: const AssetImage(
                                                      'assets/images/whatsapp.png'),
                                                  width: 20.h,
                                                  ),
                                              SizedBox(width: 8.h),
                                              buildRaisedButton(
                                                  "WhatsApp",
                                                  () => launchURL(motorizado
                                                      .telefono
                                                      .toString()) // Envuelve la llamada a launchURL en una función anónima
                                                  ),
                                              SizedBox(width: 10.h),
                                              Image(
                                                  alignment: Alignment.center,
                                                  image: const AssetImage(
                                                      'assets/images/llamadaentrante.png'),
                                                  width: 17.h),
                                              SizedBox(width: 8.h),
                                              buildRaisedButton(
                                                  "Llamar",
                                                  () => launchPhone(motorizado
                                                      .telefono
                                                      .toString())),
                                            ],
                                          )),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      /*Divider(
                        height: 8.h,
                        color: Colors.black,
                        thickness: 1.h,
                      ),
                      SizedBox(
                        height: 10.h,
                      ),*/
                      Divider(
                        height: 8.h,
                        endIndent: 5.h,
                        indent: 5.h,
                        color: Colors.black,
                        thickness: 1.h,
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Text(
                        'Productos',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.h),
                      ),
                      ScrollableWidget(
                        child: /*Column(
                      children: detalle.map((e) => listProduc(e)).toList(),
                      
                    ),*/
                            DataTable(
                          columns: const [
                            DataColumn(label: Text('Cantidad')),
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('P. Unitario')),
                            DataColumn(label: Text('Total')),
                          ],
                          rows: detalle.map((e) => listProduc(e)).toList(),
                        ),
                      ),
                      DistanciaWidget(
                        pedido: pedido,
                      ),
                      rol == "Administrador"
                          ? GestureDetector(
                              onTap: () async {
                                bool cancel = await showCustomDialog(
                                              context,
                                              options: const [
                                                "Alerta",
                                                "¿Está seguro/a de reiniciar el pedido? Va a eliminarse el motorizado de la orden y se marcará como Listo nuevamente.",
                                                "Si",
                                                "No"
                                              ]) ??
                                          false;

                                      if (cancel) {

                                Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          child: const Center(
                                              child: LoadingIndicator()))));
                                  await _pedidoService.resetEstado(pedido);
                                  Future.delayed(Duration(seconds: 1), () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  });
                                      }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 50.h, vertical: 5.h),
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
                                      "Reiniciar Pedido ",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.h,
                                      ),
                                    ),
                                    Icon(
                                      Icons.restore,
                                      color: Colors.white,
                                      size: 25.h,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                      rol == "Cliente" || rol == "Administrador" || (status != "Completado" && content["uid"] == motorizado.uid)
                    ?
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => PageLocation(
                                  pedido: pedido /*.numPedido ?? ""*/),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: EdgeInsets.symmetric(
                              horizontal: 50.h, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: CustomColors.secondaryColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Acceder Mapa ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.h,
                                ),
                              ),
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 25.h,
                              ),
                            ],
                          ),
                        ),
                      ) : Container(),
                     
                      _showButton
                          ? GestureDetector(
                              onTap: () => aceptarPedido(pedido),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 50.h, vertical: 5.h),
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
                                      "Aceptar Pedido ",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.h,
                                      ),
                                    ),
                                    Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 25.h,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                      
                      rol == "Administrador"
                          ? GestureDetector(
                              onTap: () async {
                                await FirestoreManager.instance.postData("OrdenDel", {"ord_cocinado": !pedido.cocinado!}, uid: pedido.numPedido!, edit: true);
                                SnackBarTool.showSnackbar(context,
            text:
                "Pedido marcado como ${!pedido.cocinado! ? "Listo" : "Pendiente"}.");
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
                                      "${!pedido.cocinado! ? "Marcar como" : "Cancelar"} Preparado ",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.h,
                                      ),
                                    ),
                                    Icon(
                                      Icons.restaurant,
                                      color: Colors.white,
                                      size: 25.h,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                      
                      (rol == "Cliente" && pedido.cocinado == false) || rol == "Administrador"
                          ? GestureDetector(
                              onTap: () async {
                                if (pedido.cocinado!) {
SnackBarTool.showSnackbar(context,
            text:
                "Su comida ya está preparada, no puede cancelar");
                                } else {
                                  
                                  bool cancel = await showCustomDialog(
                                              context,
                                              options: const [
                                                "Alerta",
                                                "¿Está seguro/a de cancelar el pedido?",
                                                "Si",
                                                "No"
                                              ]) ??
                                          false;

                                      if (cancel) {
                                        Navigator.of(context).pop();

                                  await FirestoreManager.instance.deleteData("OrdenDel", pedido.numPedido!);
                                  SnackBarTool.showSnackbar(context,
            text:
                "Pedido Cancelado.");
                                  
                                }}
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 50.h, vertical: 5.h),
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
                                      "Cancelar Pedido ",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.h,
                                      ),
                                    ),
                                    Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 25.h,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  void aceptarPedido(Pedido pedido) async {
    int estado;
    var numPedido = pedido.numPedido ?? "";
    var msg = "Pedido aceptado";
    var status = await _pedidoService.getEstado(numPedido);

    if (status != "Procesando" &&
        status != "Completado" &&
        status != "Entregando") {
      estado = await _pedidoService.putEstado2("Procesando", numPedido,
          setMot: true);
    } else {
      estado = 200;
      msg = "Accediendo pedido";
    }
    var rol = content["rol"];

    status = await _pedidoService.getEstado(numPedido);

    _showButton = (status != "Procesando" &&
        status != "Completado" &&
        status != "Entregando" &&
        rol != "Administrador" &&
        rol != "Cliente");

    if (mounted) {
      setState(() {});
    }

    if (estado == 200) {
      Future.delayed(Duration.zero, () {
        SnackBarTool.showSnackbar(context,
            text:
                "$msg, recuerde presionar en 'Llegué' cuando retire/entregue el producto, y debe estar a menos de 10 metros de la ubicación que debe ir.");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => PageLocation(pedido: pedido),
          ),
        );
      });
    }
  }

  DataRow listProduc(Producto detalle) {
    return DataRow(cells: [
      DataCell(Text(detalle.cantidad.toString())),
      DataCell(Text(detalle.nombre.toString())),
      DataCell(Text("${Math.round(detalle.precio!)}\$")),
      DataCell(Text("${Math.round(detalle.total!)}\$")),
    ]);
  }

  buildRaisedButton(String text, Function()? event) {
    // Cambiado el tipo de event a Function()?
    return Expanded(
      child: GestureDetector(
        child: Text(
          text,
          style: TextStyle(
              overflow: TextOverflow.ellipsis,
              fontSize: 14.h,
              color: const Color.fromRGBO(24, 71, 67, 28)),
        ),
        onTap: () {
          event?.call(); // Llama a la función event si no es null
        },
      ),
    );
  }

  Future<Pedido?> _downloadPedido() async {
    content = json.decode(mainProvider.data);
    final pedidos = await _pedidoService.getPedido(uid: numPedido);
    //await _checkShowFloatingActionButton(content["rol"]);
    if (pedidos.isEmpty) {
      return Pedido();
    }

    return pedidos.first;
  }
}
