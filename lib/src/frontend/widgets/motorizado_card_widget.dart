import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/models/usuario_model.dart';
//import 'package:prowes_motorizado/src/pages/motorizados_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:prowes_motorizado/src/frontend/pages/page_builder.dart';
import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/motorizados_widget.dart';

class MotorizadoCard extends StatelessWidget {
  const MotorizadoCard({
    Key? key, 
    required this.profileImage,
    required this.motorizado, 
    required this.role})
      : super(key: key);
  final String? profileImage;
  final Usuario motorizado;
  final String role;

  @override
  Widget build(BuildContext context) {
    
    //if (motorizado.role == role) log("${motorizado.uid}  ${motorizado.displayName} ${motorizado.role}");
    return Container(
      
      margin: EdgeInsets.symmetric(horizontal: 10.h),
      child: motorizado.role == role || (role.isEmpty && motorizado.role != "Cliente" && motorizado.role != "Administrador")
          ? Card(
              elevation: 3,
              shadowColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey, width: 1.h),
                borderRadius: BorderRadius.circular(15.h),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => PageBuilder(bodyWidget: ShowMotorizados(motorizado: motorizado)),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.all(3.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [     
                            Padding(padding: EdgeInsets.all(3.h)),            
                      CircleAvatar(
                          backgroundColor: Colors.green.shade300,
                          radius: 45.h,
                          child: ClipOval(
                            child: CachedNetworkImage(
                                width: 114.h, // El doble del radio para asegurar que sea un círculo completo
                                height: 114.h,
                                fit: BoxFit.cover,
                                imageUrl: motorizado.profileImage ?? "",
                                placeholder: (context, url) => const LoadingIndicator(color: Colors.black,),
                                errorWidget: (context, url, error) => const Icon(Icons.person),
                              ),
                          ),
                        ), 
                      Text(
                        motorizado.name ?? "",
                        style: TextStyle(
                          fontSize: 13.h,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(2.h)),
                      Text(
                        motorizado.numPlaca ?? "",
                        style: TextStyle(
                          fontSize: 15.h,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Telefono: ${motorizado.telefono}"),
                      Padding(padding: EdgeInsets.all(2.h)),
                    ],
                  ),
                ),
              ),
            )
          : null,
    
    );
  }
}
