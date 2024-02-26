import 'package:firedart/firedart.dart';
import 'package:flutter/material.dart';
//import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';
import 'package:prowes_motorizado/src/frontend/pages/page_builder.dart';
import 'package:prowes_motorizado/src/frontend/widgets/titles/button_title.dart';
import 'package:prowes_motorizado/src/frontend/widgets/buttons/checkout_button.dart';
//import 'package:prowes_motorizado/src/frontend/widgets/carrito_card_builder_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/carrito_widget.dart';
//import 'package:prowes_motorizado/src/firestore/firestore_manager.dart';
import 'package:prowes_motorizado/src/frontend/widgets/delivery_widget_user.dart';
import 'package:prowes_motorizado/src/frontend/widgets/user_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/opciones_widget.dart';
//import 'package:prowes_motorizado/src/pages/pre_carrito_page.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';
//import 'dart:convert';
//import 'package:prowes_motorizado/src/provider/main_provider.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:prowes_motorizado/src/frontend/widgets/details_order_user_widget.dart';
import 'dart:developer';

class HomeClientPage extends StatefulWidget {
  const HomeClientPage({Key? key}) : super(key: key);

  @override
  State<HomeClientPage> createState() => _HomePageState();
}

class _HomePageState extends State<HomeClientPage> {
  late PageController _pageController = PageController();
  int selectedIndex = 1;
  //late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedIndex);
  }

  void onButtonPressed(int index) {
    if (mounted) {
      setState(() => selectedIndex = index);
    }
    _pageController.animateToPage(selectedIndex,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOutQuad);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CustomColors.primaryColor, //
              CustomColors.primaryColor, //
              CustomColors.primaryColor, //
            ],
          )),
        ),
        toolbarHeight: 50.h,
        centerTitle: false, // Cambiar a false
        elevation: 10.h,
        title: Row(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 20.h),
              child: Image.asset(
                'assets/images/Logo_2.1.png',
                fit: BoxFit.contain,
                height: 100.h,
                width: 100.h,
              ),
            ),
            Spacer(), // Añadir Spacer para ocupar el espacio restante
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PageBuilder(
                        bodyWidget: CarritoWidget(),
                        title: ButtonTitle(bodyWidget: CheckOutButton()),
                      ),
                    ));
              },
              child: Container(
                padding: const EdgeInsets.all(5.0),
                margin: EdgeInsets.symmetric(horizontal: 0.h, vertical: 0.h),
                decoration: BoxDecoration(
                  color: CustomColors.secondaryColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Ver Carrito ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.h,
                      ),
                    ),
                    Icon(
                      Icons.shopping_cart_checkout_sharp,
                      color: Colors.white,
                      size: 15.h,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: const <Widget>[
          UserWidget(),
          DeliveryWidgetUser(),
          DetailsUser(),
          OpcionesWidget(),
        ],
      ),
      bottomNavigationBar: SlidingClippedNavBar(
        backgroundColor: CustomColors.primaryColor,
        onButtonPressed: onButtonPressed,
        iconSize: 32.h,
        activeColor: Colors.white,
        selectedIndex: selectedIndex,
        barItems: <BarItem>[
          BarItem(icon: Icons.person_outline, title: 'Perfil'),
          BarItem(icon: Icons.local_mall, title: 'Productos'),
          BarItem(icon: Icons.local_shipping, title: 'Pedidos'),
          BarItem(icon: Icons.contact_mail, title: 'Contacto'),
        ],
      ),
    );
  }
}
