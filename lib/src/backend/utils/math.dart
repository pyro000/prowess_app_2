class Math {
  static String round(double number) {
    String rounded = number.toStringAsFixed(2);
    if (rounded.endsWith('.00') || rounded.endsWith('.0')) {
      return number.toInt().toString();
    }
    return rounded;
  }
}