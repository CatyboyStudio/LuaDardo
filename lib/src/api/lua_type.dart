import 'dart:io';
import 'dart:typed_data';

import 'lua_state.dart';

/// basic ypes
enum LuaType {
  luaNil,
  luaBoolean,
  luaLightUserdata,
  luaNumber,
  luaString,
  luaTable,
  luaFunction,
  luaUserdata,
  luaThread,
  luaNone,
}

/// arithmetic functions
enum ArithOp {
  luaOpAdd, // +
  luaOpSub, // -
  luaOpMul, // *
  luaOpMod, // %
  luaOpPow, // ^
  luaOpDiv, // /
  luaOpIdiv, // //
  luaOpBand, // &
  luaOpBor, // |
  luaOpBxor, // ~
  luaOpShl, // <<
  luaOpShr, // >>
  luaOpUnm, // -
  luaOpBnot, // ~
}

/// comparison functions
enum CmpOp {
  luaOpEq, // ==
  luaOpLt, // <
  luaOpLe, // <=
}

enum ThreadStatus {
  luaOk,
  luaYield,
  luaErrRun,
  luaErrSyntax,
  luaErrMem,
  luaErrGcmm,
  luaErrErr,
  luaErrFile,
}

typedef DartFunction = int Function(LuaState ls);

typedef FileReadFunction = (Uint8List, String) Function(String filename);

(Uint8List, String) defaultFileRead(String filename) {
  File file = File(filename);
  return (file.readAsBytesSync(), filename);
}

typedef FileExistsFunction = (bool, bool) Function(String path);

(bool, bool) defaultFileExists(String filename) {
  if (File(filename).existsSync()) {
    return (true, true);
  } else {
    if (Directory(filename).existsSync()) {
      return (true, false);
    } else {
      return (false, false);
    }
  }
}
