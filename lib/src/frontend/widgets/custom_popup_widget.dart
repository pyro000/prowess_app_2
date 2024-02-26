import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';

class CustomPopupNotification extends StatefulWidget {
  final String message;
  final Function? onAccept;
  final Function? onReject;
  final List<String>? options;
  final Function? onDismissed;

  const CustomPopupNotification({
    Key? key,
    required this.message,
    this.onAccept,
    this.onReject,
    this.options,
    this.onDismissed,
  }) : super(key: key);

  @override
  _CustomPopupNotificationState createState() => _CustomPopupNotificationState();

}

class _CustomPopupNotificationState extends State<CustomPopupNotification>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _barController;
  late Animation<double> _slideAnimation;
  late List<String> options;
  bool isClosed = false;
  //late Animation<double> _barAnimation;

  @override
  void initState() {
    
    options = widget.options ?? ["Aceptar", "Rechazar"];

    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..addListener(() {
        setState(() {});
      });

    _barController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });

    _animationController.forward();

    _slideAnimation = Tween<double>(
      begin: -100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Oculta la notificación cuando la animación finaliza
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _barController.forward();

        _barController.addStatusListener((status1) {
          if (status1 == AnimationStatus.completed) {
            _animationController.reverse();
            Future.delayed(Duration(seconds: 1), () {
              //log("hello?");
              widget.onDismissed?.call();
              isClosed = true;
            });
            
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return !isClosed ? 
    
    LayoutBuilder(
      builder: (context, constraints) {
        return 
        
        SizedBox(
          height: constraints.maxHeight,
          child: Stack(
            children: [
    
    Positioned(
      top: _slideAnimation.value,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _animationController.value > 0 ? 1 : 0,
        duration: Duration(milliseconds: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(top: 15, bottom: 5),
              child: Column(
                children: [
                  Text(
                    widget.message,
                    style: TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(CustomColors.secondaryColor),
                        ),
                        onPressed: () {
                          _animationController.stop();
                          if (widget.onAccept != null) {
                            widget.onAccept!();
                          }
                        },
                        child: Text(options[0]),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(CustomColors.secondaryColor),
                        ),
                        onPressed: () {
                          _animationController.stop();
                          if (widget.onReject != null) {
                            widget.onReject!();
                          } else {
                            isClosed = true;
                          }
                        
                        },
                        child: Text(options[1]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 0), // Barrita delgada
            LinearProgressIndicator(
              value: 1 - _barController.value,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red), // Cambia el color de la barra
            ),
          ],
        ),
      ),
    ),]));}) : Container();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _barController.dispose();
    super.dispose();
  }
}
