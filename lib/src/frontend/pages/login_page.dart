import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/bloc/login_bloc.dart';
import 'package:prowes_motorizado/src/backend/models/usuario_model.dart';
import 'package:prowes_motorizado/src/frontend/pages/page_builder.dart';
//import 'package:prowes_motorizado/src/pages/recovery_password_page.dart';
import 'package:prowes_motorizado/src/frontend/pages/singup_user_page.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'package:prowes_motorizado/src/backend/services/usuario_services.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:prowes_motorizado/src/backend/utils/snack_bar.dart';
import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/recovery_password_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  final LoginBloc _loginBloc = LoginBloc();
  bool _onSaving = false;

  @override
  Widget build(BuildContext context) {
    final mainProvider = MainProvider.instance;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 50.h),
            margin: EdgeInsets.all(12.h),
            color: const Color.fromRGBO(
                255, 255, 255, 1), //color de fondo segun el logo
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Center(
                    child: Image.asset(
                      'assets/images/Logo_1.png',
                      width: 200.h,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10.h, 0, 10.h),
                  child: Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25.h,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      StreamBuilder<String>(
                        stream: _loginBloc.emailStream,
                        builder: (context, snapshot) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color.fromRGBO(0, 126, 104, 49),
                              ),
                            ),
                            child: TextField(
                              onChanged: _loginBloc.changeEmail,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                errorText: snapshot.error?.toString(),
                                icon: const Icon(Icons.email_outlined),
                                labelText: "Correo electrónico",
                              ),
                            ),
                          );
                        },
                      ),
                      StreamBuilder<Object>(
                        stream: _loginBloc.passwordStream,
                        builder: (context, snapshot) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color.fromRGBO(0, 126, 104, 49),
                              ),
                            ),
                            child: TextField(
                              onChanged: _loginBloc.changePassword,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                errorText: snapshot.error?.toString(),
                                icon: const Icon(Icons.lock_outline),
                                labelText: "Contraseña",
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    _obscureText = !_obscureText;
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 18.h),
                  child: StreamBuilder<bool>(
                    stream: _loginBloc.formLoginStream,
                    builder: (context, snapshot) {
                      return _onSaving
                          ? Container(
                              padding: EdgeInsets.all(12.h),
                              child: SizedBox.square(
                                dimension: 25.h,
                                child: const LoadingIndicator(),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: snapshot.hasData
                                  ? () async {
                                      if (mounted) {
                                        setState(() => _onSaving = true);
                                      }
                                      await Future.delayed(
                                          const Duration(seconds: 2));
                                      if (mounted) {
                                        setState(() => _onSaving = false);
                                      }
                                      final usrSrv = UsuarioService();
                                      final usr = Usuario(
                                          //Modelo
                                          email: _loginBloc.email,
                                          password: _loginBloc.password);

                                      Map<String, dynamic> resp =
                                          await usrSrv.login2(usr);

                                      if (resp.isNotEmpty) {
                                        mainProvider.lastLogin =
                                            DateTime.now().toString();
                                        mainProvider.data = json.encode(resp);
                                      } else {
                                        SnackBarTool.showSnackbar(
                                          context, 
                                          text: "Usuario y/o Contraseña incorrectos...",
                                        );
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                primary: const Color.fromRGBO(0, 126, 104, 49),
                                onPrimary:
                                    const Color.fromRGBO(0, 126, 104, 49),
                                minimumSize: const Size(300, 40),
                                elevation: 50.h,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.h)),
                              ),
                              child: Text(
                                'Ingresar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17.h,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                    },
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            //const RecoveryPasswordPage(),
                            PageBuilder(bodyWidget: const RecoveryPassword(), title: Container(), colored: false,)
                      ),
                    );
                  },
                  child: const Text(
                    "¿Olvidaste tu contraseña?",
                    style: TextStyle(
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const SignUpUserPage(role: "Cliente"),
                      ),
                    );
                  },
                  child: const Text(
                    "¡Regístrate ahora!",
                    style: TextStyle(
                      color: CustomColors.secondaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 25,
                    ),
                  ),
                ),
                InkWell(
                  child: Text(
                    "",
                    style: TextStyle(
                        color: const Color.fromRGBO(0, 126, 104, 49),
                        fontSize: 18.h,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                    child: Text(
                      "Ayuda",
                      style: TextStyle(
                          color: const Color.fromRGBO(255, 99, 71, 1),
                          fontSize: 18.h,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () => launch('https://prowessec.com/ayuda/')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
