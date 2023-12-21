import 'dart:typed_data';

abstract class LuaAdapter {
  String get dirsep;

  (Uint8List, String) execFileRead(String filename);

  (bool, bool) execFileExists(String path);
}
