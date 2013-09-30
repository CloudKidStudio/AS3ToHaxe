AS3 to Haxe Conversion Script
======================================

Simple utility to convert AS3 source code into Haxe.

Using
------

```bash
neko AS3ToHaxe.n -from pathToSource -to targetDirectory [-remove true]
```

Substitutions
--------------------

| AS3 Example                    | Translated to Haxe           |
|--------------------------------|------------------------------|
| `package com.example{}`        | `package com.example;`       |
| `public class Something`       | `class Something`            |
| `public function Constructor()`| `public function new()`      |
| `protected var`                | `private var`                |
| `internal var`                 | `private var `               |
| `protected function`           | `private function`           |
| `internal function`            | `private function `          |
| `public static const`          | `public static inline var`   |
| `:Number`, `<Number>`          | `:Float`,`<Float>`           |
| `:int`, `<int>`                | `:Int`, `<Int>`              |
| `:uint`, `<uint>`              | `:UInt`, `<UInt>`            |
| `:Boolean`, `<Boolean>`        | `:Bool`, `<Bool>`            |
| `:void`                        | `:Void`                      |
| `undefined`                    | `null`                       |
| `===`                          | `==`                         |
| `!==`                          | `!=`                         |
| `final class`                  | `@:final class`              |
| `[Event(type="", name="")]`    | `@:meta(Event(type="",name=""))` |
| `getQualifiedClassName(type)`  | `Type.getClassName(type)`    |
| `getDefinitionByName(name)`    | `Type.getClass(name)`        |
| `:*`                           | `:Dynamic`                   |
| `Vector.<String>`              | `Vector<String>`             |
| `Number("10.1")`               | `Std.parseFloat("10.1")`     |
| `int(10.1)`                    | `Std.int(10.1)`              |
| `int("10.1")`                  | `Std.parseInt("10.1)`        |
| `String(10)`                   | `Std.string(10)`             |
| `MovieClip(clip)`              | `cast(clip, MovieClip)`      |
| `clip as MovieClip`            | `cast(clip, MovieClip)`      |
| `clip is MovieClip`            | `Std.is(clip, MovieClip)`    |
| `Array`                        | `Array<Dynamic>`             |
| `new Error()`                  | Add import: `import flash.Error;`   |
| `public function get data():String` | `private function get_data():String` |
| `public function set data(data:String): void` | `private function set_data(data:String):String` |
| `public function get data`, `public function set data` | `public var data(get, set)` |
| `for (var i:int; i < 10; i++)` | `for (i in 0...10)`          |
| `for each (var i:String in items)` | `for (i in items)`       |
| `for (var k:String in items)`  | `var fields = Reflect.fields(items); for(k in fields)`


Rebuilding AS3ToHaxe
--------------------

```bash
cd AS3ToHaxe
ant
```

Todo
----

###Haxe doesn't support lower case imports like this:
```as3
import flash.utils.getQualifiedClassName;
import flash.utils.getTimer;
import flash.utils.setTimeout;
```  
So convertor should remove imports and put in code those strings, like in this example:

AS3:
```as3
var a:int = getTimer();
``` 
Should be changed to:
```
var a:int = flash.utils.getTimer();
```

###Convert Vector to Array

Replace Vector with Array
```as3
Vector.<Sprite>
```   
To
```
Array<Sprite>
```

###Change Vector arrays initializations to Array
AS3 code like this:
```as3
var a:Vector.<MyClass> = new <MyClass> [new MyClass()];
```	
To
```
var a:Array<MyClass> = new Array<MyClass>();
a.push(new MyClass());
```

And should be checked other things and changed like in this article.
http://www.nme.io/developer/guides/actionscript-developers/

Credits
-------
Original code can be found here: 
http://pastebin.com/s0VccheL