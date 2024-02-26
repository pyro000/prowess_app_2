import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/models/usuario_model.dart';
import 'package:prowes_motorizado/src/backend/models/producto_model.dart';
import 'package:prowes_motorizado/src/backend/services/launch_services.dart';
import 'package:prowes_motorizado/src/frontend/widgets/scrollable_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/pedidos_motorizado_widget.dart';

class ShowMotorizados extends StatefulWidget {
  const ShowMotorizados({Key? key, required this.motorizado}) : super(key: key);
  final Usuario motorizado;

  @override
  State<ShowMotorizados> createState() => _ShowMotorizadosState();
}

class _ShowMotorizadosState extends State<ShowMotorizados> {
  @override
  void initState() {
    super.initState();
  }

  bool _actPedidos = false;

  @override
  Widget build(BuildContext context) {
    Usuario motorizado = widget.motorizado;

    return SingleChildScrollView(
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
                          child:
                              Image.asset('assets/images/delivery-truck.png'),
                        ),
                        SizedBox(width: 15.h),
                        Text(
                          "Ver Motorizado",
                          style: TextStyle(
                            fontSize: 21.h,
                            fontWeight: FontWeight.bold,
                          ),
                        )
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
                            SizedBox(
                              height: 40.h,
                              width: 40.h,
                              child: Image.asset('assets/images/vendedor.png'),
                            ),
                            ScrollableWidget(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Row(
                                    children: const [
                                      Text(
                                        'Motorizado',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(10.h, 0, 0, 0),
                                    child: Text('Nombre: ' +
                                        motorizado.name.toString()),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(10.h, 0, 0, 0),
                                    child: Text('Telefono: ' +
                                        motorizado.telefono.toString()),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(10.h, 0, 0, 0),
                                    child: Text('Lic: ' +
                                        motorizado.tipoLic.toString()),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(10.h, 0, 0, 0),
                                    child: Text('Direccion: ' +
                                        motorizado.sector.toString()),
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 8.h,
                          color: Colors.black,
                          thickness: 1.h,
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          children: [
                            Image(
                                alignment: Alignment.center,
                                image: const AssetImage(
                                    'assets/images/whatsapp.png'),
                                width: 25.h),
                            SizedBox(width: 8.h),
                            buildRaisedButton(
                                "Enviar un mensaje a comprador", () => launchURL(motorizado.telefono.toString())),
                            Image(
                                alignment: Alignment.center,
                                image: const AssetImage(
                                    'assets/images/llamadaentrante.png'),
                                width: 25.h),
                            SizedBox(width: 8.h),
                            buildRaisedButton(
                                "Llamar a comprador", () => launchPhone(motorizado.telefono.toString())),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 8.h,
                    endIndent: 5.h,
                    indent: 5.h,
                    color: Colors.black,
                    thickness: 1.h,
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(25.h, 5.h, 25.h, 5.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.h),
                      borderRadius: BorderRadius.circular(18.h),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.h),
                                child: Image(
                                  image: const AssetImage(
                                      'assets/images/pedido.png'),
                                  width: 30.h,
                                ),
                              ),
                              Text(
                                "Pedidos Realizados",
                                style: TextStyle(
                                    fontSize: 16.h,
                                    fontWeight: FontWeight.bold),
                              ),
                              Icon(
                                !_actPedidos
                                    ? Icons.navigate_next
                                    : Icons.arrow_drop_down,
                                color: Colors.grey,
                              )
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              _actPedidos = !_actPedidos;
                            });
                          },
                        ),
                        if (_actPedidos)
                          PedidoMotorizado(uid: motorizado.uid ?? ""),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      //),
    );
  }

  Widget listProduc(Producto detalle) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Cantidad')),
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('P. Unitario')),
        DataColumn(label: Text('Total')),
      ],
      rows: [
        DataRow(cells: [
          DataCell(Text(detalle.cantidad.toString())),
          DataCell(Text(detalle.nombre.toString())),
          DataCell(Text(detalle.precio.toString())),
          DataCell(Text(detalle.total.toString())),
        ]),
      ],
    );
  }

  buildRaisedButton(String text, Function()? event) {
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
          event?.call();
        },
      ),
    );
  }
}
