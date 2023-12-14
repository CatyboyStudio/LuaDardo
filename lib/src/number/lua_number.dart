class LuaNumber {
  static bool isInteger(double f) {
    return f == f.toInt();
  }

  // TODO2
  static int? parseInteger(String str) {
    try {
      return int.parse(str);
    } catch (e) {
      return null;
    }
  }

  // TODO2
  static double? parseFloat(String str) {
    try {
      return double.parse(str);
    } catch (e) {
      return null;
    }
  }
}
