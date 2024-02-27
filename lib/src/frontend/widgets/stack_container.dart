import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';

class StackContainer extends StatelessWidget {
  const StackContainer({
    Key? key,
    required String? imagenPerfil,
    required this.content,
    required this.mainProvider,
    required this.isadmin,
  })  : _imagenPerfil = imagenPerfil,
        super(key: key);

  final String? _imagenPerfil;
  final Map<String, dynamic> content;
  final MainProvider mainProvider;
  final bool isadmin;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Container(
      height: 278.0,
      child: Stack(
        children: <Widget>[
          //Container(),
          ClipPath(
            clipper: MyCustomClipper1(),
            child: Container(
              height: 180.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/${isadmin ? "admin_1" : "motorizado_1"}.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(), // Evita el scroll
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: w * 0.9,
                    height: h * 0.25,
                    decoration: BoxDecoration(
                      color: CustomColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 6,
                          offset: const Offset(1, 1),
                          color: CustomColors.primaryColor.withOpacity(0.4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 7.h),
                        CircleAvatar(
                          backgroundColor: CustomColors.primaryColor,
                          radius: 61.h,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              width: 114
                                  .h, // El doble del radio para asegurar que sea un círculo completo
                              height: 114.h,
                              fit: BoxFit.cover,
                              imageUrl: _imagenPerfil.toString(),
                              placeholder: (context, url) =>
                                  const LoadingIndicator(color: Colors.black),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.person),
                            ),
                          ),
                        ),
                        SizedBox(height: 7.h),
                        Text(
                          content["nombres"],
                          style: TextStyle(
                              fontSize: 17.h, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 0.09.h), // La ubicación del botón
                  Container(
                    width: w * 0.4,
                    height: h * 0.06,
                    margin: EdgeInsets.only(
                        bottom: 17.h), // Ajusta el valor según lo desees
                    child: InkWell(
                      child: (Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: w * 0.4,
                            height: h * 0.06,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                    offset: Offset(1, 1),
                                    color: CustomColors.primaryColor,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      tooltip: 'Cerrar Sesión',
                                      onPressed: () {
                                        mainProvider.lastLogin = "";
                                        mainProvider.data = "";
                                      },
                                      icon: const Icon(Icons.logout,
                                          color: Colors.white),
                                    ),
                                    const Text(
                                      "Cerrar Sesión",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                      onTap: () {
                        mainProvider.lastLogin = "";
                        mainProvider.data = "";
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyCustomClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 165);
    path.lineTo(0, size.height);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
