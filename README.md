# LuaDardo

![logo](https://github.com/arcticfox1919/ImageHosting/blob/master/language_logo.png?raw=true)

------

A Lua virtual machine written in [Dart](https://github.com/dart-lang/sdk), which implements [Lua5.3](http://www.lua.org/manual/5.3/) version.

## Example:

```yaml
dependencies:
  lua_dardo: ^0.0.3
```

```dart
import 'package:lua_dardo/lua.dart';


void main(List<String> arguments) {
  LuaState state = LuaState.newState();
  state.openLibs();
  state.loadString(r'''
a=10
while( a < 20 ) do
   print("a value is", a)
   a = a+1
end
''');
  state.call(0, 0);
}
```

## Try on Flutter

![](https://gitee.com/arcticfox1919/ImageHosting/raw/master/img/GIF_2021-5-11_21-44-49.gif)

```lua
function getContent1()
    return Row:new({
        children={
            GestureDetector:new({
                onTap=function()
                    flutter.debugPrint("--------------onTap--------------")
                end,

                child=Text:new("click here")}),
            Text:new("label1"),
            Text:new("label2"),
            Text:new("label3"),
        },
        mainAxisAlign=MainAxisAlign.spaceEvenly,
    })
end

function getContent2()
    return Column:new({
        children={
            Row:new({
                children={Text:new("Hello"),Text:new("Flutter")},
                mainAxisAlign=MainAxisAlign.spaceAround
            }),
            Image:network('https://gitee.com/arcticfox1919/ImageHosting/raw/master/img/flutter_lua_test.png'
                ,{fit=BoxFit.cover})
        },
        mainAxisSize=MainAxisSize.min,
        crossAxisAlign=CrossAxisAlign.center
    })
end
```

**For use in flutter, see [here](https://github.com/arcticfox1919/flutter_lua_dardo).**

------
一些中文资料：

[Flutter 热更新及动态UI生成](https://arcticfox.blog.csdn.net/article/details/116681188)

[Lua 15分钟快速上手（上）](https://arcticfox.blog.csdn.net/article/details/119516215)

[Lua 15分钟快速上手（下）](https://arcticfox.blog.csdn.net/article/details/119535814)

[Lua与C语言的互相调用](https://arcticfox.blog.csdn.net/article/details/119544987)

[LuaDardo中Dart与Lua的相互调用](https://arcticfox.blog.csdn.net/article/details/119582403)
