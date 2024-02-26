import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/frontend/widgets/admin_perfil_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/transporte_widget.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late PageController _pageController = PageController();
  int selectedIndex = 1;

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
        centerTitle: true,
        elevation: 10.h,
        title: Stack(
          alignment: Alignment.topRight,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
              ],
            ),
          ],
        ),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: _listOfWidget,
      ),
      bottomNavigationBar: SlidingClippedNavBar(
        backgroundColor: CustomColors.primaryColor,
        onButtonPressed: onButtonPressed,
        iconSize: 32.h,
        activeColor: Colors.white,
        selectedIndex: selectedIndex,
        barItems: <BarItem>[
          BarItem(icon: Icons.person_outline, title: 'Perfil'),
          BarItem(icon: Icons.format_list_bulleted, title: 'Opciones'),
        ],
      ),
    );
  }
}

List<Widget> _listOfWidget = <Widget>[
  const AdminPerfil(),
  const TransporteWidget(),
];
