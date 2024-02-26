import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:provider/provider.dart';
import 'package:prowes_motorizado/src/frontend/pages/home_page.dart';
import 'package:prowes_motorizado/src/frontend/pages/home_client_page.dart';
import 'package:prowes_motorizado/src/frontend/pages/login_page.dart';
import 'package:prowes_motorizado/src/frontend/pages/page_builder.dart';
import 'package:prowes_motorizado/src/frontend/pages/singup_transporte_page.dart';
import 'package:prowes_motorizado/src/backend/provider/connectivity_provider.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'package:prowes_motorizado/src/frontend/pages/admin_page.dart';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:prowes_motorizado/src/frontend/widgets/no_internet_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/no_location_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  checkConnectivityAndRunApp();
}

Future<void> checkConnectivityAndRunApp() async {
  if (Platform.isAndroid) {
    try {
      await GoogleMapsFlutterAndroid().initializeWithRenderer(AndroidMapRenderer.latest);
    } on PlatformException catch (e) {
      log("Err Renderer Google Maps: $e");
    }
  }

  final connectivityResult = await Connectivity().checkConnectivity();

  await Firebase.initializeApp(); // Inicializar esto primero
  if (connectivityResult != ConnectivityResult.none) {
    // Si hay conexión a Internet, inicializa Firebase y Firestore
    await FirestoreManager.instance.connect();
  }

  // Ejecuta la aplicación independientemente de si hay conexión o no
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityProvider =
        Provider.of<ConnectivityProvider>(context, listen: true);
    final mainProvider = MainProvider.instance;

    return FutureBuilder(
      future: connectivityProvider.initConectivity(),
      builder: (context, snapshot) {
        DateTime dateNow = DateTime.now();

        DateTime? dateLast;
        Duration? dif;
        dynamic data;
        if (mainProvider.lastLogin.isNotEmpty) {
          dateLast = DateTime.parse(mainProvider.lastLogin);
          dif = dateNow.difference(dateLast);
          data = json.decode(mainProvider.data);
        }

        return FutureBuilder<void>(
          future: mainProvider.initPrefs(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const SizedBox.square(
                  dimension: 150.0, child: Text("Ha ocurrido un error"));
            }

            if (snapshot.hasData) {
              return ScreenUtilInit(
                designSize: const Size(360, 690),
                builder: (BuildContext context, child) => MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Prowess Agronomía',
                  //theme: AppTheme.themeData(mainProvider.mode),
                  routes: {
                    "/noInternet": (context) => const PageBuilder(bodyWidget: NoInternet()),
                    "/login": (context) => const LoginPage(),
                    "/signup": (context) => const SingUpPage()
                  },
                  home: connectivityProvider.isOnline && FirestoreManager.instance.connected
                      ? connectivityProvider.isLocationEnabled && connectivityProvider.isPermission ? mainProvider.lastLogin == ""
                          ? const LoginPage()
                          : dif == null || dif.inDays > 7
                              ? const LoginPage()
                              : data["rol"] == "Administrador"
                                  ? const AdminPage()
                                  : data["rol"] == "Cliente"
                                      ? const HomeClientPage()
                                      : const HomePage()
                      : const PageBuilder(bodyWidget: NoLocation(), navigation: false,) :
                      const PageBuilder(bodyWidget: NoInternet(), navigation: false,)
                      ,
                ),
              );
            }

            return const SizedBox.square(
                dimension: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      CustomColors.secondaryColor),
                ));
          },
        );
      },
    );
  }
}
