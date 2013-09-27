AS3 to Haxe Conversion Script
======================================

Simple utility to convert AS3 source code into Haxe.

Using
------

```bash
neko AS3ToHaxe.n -from pathToSource -to targetDirectory [-remove true]
```

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

###Replace those dynamic params
```as3
function test (...params):void {
}
```
Change to:
```
function test (params:Array<Dynamic>) {
}
```   
 
###Final vars should be replaced with this tag 
```
@:final
``` 
And should be checked other things and changed like in this article.
http://www.nme.io/developer/guides/actionscript-developers/

Credits
-------
Original code can be found here: 
http://pastebin.com/s0VccheL