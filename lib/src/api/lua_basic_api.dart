import 'dart:typed_data';

import 'package:lua_dardo/lua.dart';

abstract class LuaBasicAPI {
/* basic stack manipulation */
  int getTop();

  int absIndex(int idx);

  bool checkStack(int n);

  void pop(int n);

  void copy(int fromIdx, int toIdx);

  void pushValue(int idx);

  void replace(int idx);

  void insert(int idx);

  void remove(int idx);

  void rotate(int idx, int n);

  void setTop(int idx);

/* access functions (stack -> Go); */
  String typeName(LuaType tp);

  LuaType type(int idx);

  bool isNone(int idx);

  bool isNil(int idx);

  bool isNoneOrNil(int idx);

  bool isBoolean(int idx);

  bool isInteger(int idx);

  bool isNumber(int idx);

  bool isString(int idx);

  bool isTable(int idx);

  bool isThread(int idx);

  bool isFunction(int idx);

  bool isDartFunction(int idx);

  bool isUserdata(int idx);

  bool toBoolean(int idx);

  int toInteger(int idx);

  int? toIntegerX(int idx);

  double toNumber(int idx);

  double? toNumberX(int idx);

  String? toStr(int idx);

  DartFunction? toDartFunction(int idx);

  Object? toPointer(int idx);

  Userdata<T>? toUserdata<T>(int idx);

  int rawLen(int idx);

/* push functions (Go -> stack); */
  void pushNil();

  void pushBoolean(bool b);

  void pushInteger(int? n);

  void pushNumber(double n);

  void pushString(String? s);

  void pushFString(String fmt, [List<Object>? a]);

  void pushDartFunction(DartFunction f);

  void pushDartClosure(DartFunction f, int n);

  void pushGlobalTable();

/* comparison and arithmetic functions */
  void arith(ArithOp op);

  bool compare(int idx1, int idx2, CmpOp op);

  bool rawEqual(int idx1, int idx2);

/* get functions (Lua -> stack) */
  void newTable();

  Userdata<T> newUserdata<T>();

  void createTable(int nArr, int nRec);

  LuaType getTable(int idx);

  LuaType getField(int idx, String? k);

  LuaType getI(int idx, int i);

  LuaType rawGet(int idx);

  LuaType rawGetI(int idx, int i);

  LuaType getGlobal(String name);

  bool getMetatable(int idx);

/* set functions (stack -> Lua) */
  void setTable(int idx);

  void setField(int idx, String? k);

  void setI(int idx, int? i);

  void rawSet(int idx);

  void rawSetI(int idx, int i);

  void setMetatable(int idx);

  void setGlobal(String name);

  void register(String name, DartFunction f);

/* 'load' and 'call' functions (load and run Lua code) */
  ThreadStatus load(Uint8List chunk, String chunkName, String? mode);

  void call(int nArgs, int nResults);

  ThreadStatus pCall(int nArgs, int nResults, int msgh);

/* miscellaneous functions */
  void len(int idx);

  void concat(int n);

  bool next(int idx);

  int error();

  bool stringToNumber(String s);
}

int pushDartData(LuaState ls, Object? data) {
  if (data != null) {
    switch (data) {
      case bool b:
        ls.pushBoolean(b);
        break;
      case int i:
        ls.pushInteger(i);
        break;
      case double d:
        ls.pushNumber(d);
        break;
      case String s:
        ls.pushString(s);
        break;
      case Map m:
        ls.newTable();
        m.forEach((key, value) {
          pushDartData(ls, key);
          pushDartData(ls, value);
          ls.setTable(-3);
        });
        break;
      case List l:
        ls.newTable();
        for (int i = 0; i < l.length; i++) {
          ls.pushInteger(i + 1);
          pushDartData(ls, l[i]);
          ls.setTable(-3);
        }
        break;
      default:
        ls.pushString(data.runtimeType.toString());
    }
  } else {
    ls.pushNil();
  }
  return 1;
}

int pushDartListData(LuaState ls, List<dynamic>? data) {
  if (data != null) {
    for (var e in data) {
      pushDartData(ls, e);
    }
    return data.length;
  }
  return 0;
}

Object? popDartData(LuaState ls) {
  var o = toDartData(ls, -1);
  ls.pop(1);
  return o;
}

Object? toDartData(LuaState ls, int i) {
  LuaType t = ls.type(i);
  switch (t) {
    case LuaType.luaNone:
      return null;
    case LuaType.luaNil:
      return null;
    case LuaType.luaBoolean:
      return ls.toBoolean(-1);
    case LuaType.luaNumber:
      if (ls.isInteger(i)) {
        return ls.toInteger(i);
      } else if (ls.isNumber(i)) {
        return ls.toNumber(i);
      }
      return null;
    case LuaType.luaString:
      return ls.toStr(i);
    case LuaType.luaTable:
      {
        bool? array;
        Map<String, Object?>? m;
        List<Object?>? l;
        var tidx = ls.absIndex(i);
        // len
        ls.len(i);
        var c = ls.toInteger(i);
        ls.pop(1);
        // for each
        ls.pushNil();
        while (ls.next(tidx)) {
          // uses 'key' (at index -2) and 'value' (at index -1)
          if (array == null) {
            if (ls.isInteger(-2)) {
              array = true;
            } else {
              array = false;
            }
          }
          var key = toDartData(ls, -2);
          var value = toDartData(ls, -1);
          if (array) {
            l ??= List.filled(c, null, growable: true);
            if (key is int) {
              var idx = key - 1;
              if (idx < l.length) {
                l[idx] = value;
              }
            }
          } else {
            m ??= {};
            m[key?.toString() ?? ""] = value;
          }
          // removes 'value'; keeps 'key' for next iteration
          ls.pop(1);
        }
        if (array ?? false) {
          return l;
        } else {
          return m;
        }
      }
    // case LuaType.luaLightUserdata:
    // case LuaType.luaFunction:
    // case LuaType.luaUserdata:
    // case LuaType.luaThread:
    default:
      return ls.typeName(t);
  }
}

int _callbackId = 0;
const _callbackTableName = "--system_callback--";

int pushCallback(LuaState ls, int idx) {
  var id = ++_callbackId;
  ls.getGlobal(_callbackTableName);
  if (!ls.isTable(-1)) {
    ls.newTable();
    ls.setGlobal(_callbackTableName);
    ls.getGlobal(_callbackTableName);
  }
  ls.pushValue(idx);
  var name = "callback$id";
  ls.setField(-2, name);
  return id;
}

void popCallback(LuaState ls, int id, bool keep) {
  ls.getGlobal(_callbackTableName);
  if (ls.isTable(-1)) {
    var name = "callback$id";
    ls.getField(-1, name);
    if (!keep) {
      ls.pushNil();
      ls.setField(-3, name);
    }
  } else {
    ls.pushNil();
  }
}

int pushBytes(LuaState state, Uint8List bs) {
  var u = state.newUserdata<Uint8List>();
  u.data = bs;
  return 1;
}

Uint8List? toBytes(LuaState state, int idx) {
  return state.toUserdata<Uint8List>(idx)?.data;
}
