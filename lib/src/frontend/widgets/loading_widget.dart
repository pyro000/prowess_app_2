import 'package:flutter/material.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key, this.color = CustomColors.secondaryColor}) : super(key: key);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(CustomColors.secondaryColor),
      ),
    );
  }
}
