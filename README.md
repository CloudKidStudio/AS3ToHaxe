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
###1.Getters/Setters

AS3:
```as3
function get x():Number {
	return _x;
}
function set x(value:Number):Number {
	_x = value;
} 
```
Should be replaced to this:
```
public var x(getX, setY):Float
function getX ():Float
{
	return _x;
}

function setX (value:Float):Float
{
	return _x = value;
}
```

###2.cast

AS3:
```as3
sprite as Sprite
```  
Should be replaced to this:
```
cast(sprite, Sprite)
```
Where sprite is instance, Sprite is a class.

###3.for each

AS3 For each loops
```as3
for each(var i:Item in items)
{
}
```	
Should be ported to:
```
for (i in items)
{
}
```

###4.for

AS3 Loops like this:
```as3
for (var i:int=0; i<10; ++i)
{
}
```  
Should be ported to:
```
for (i in 0...10)
{
}
```

###5.is

AS3 "is" like 
```as3
(1 is Int)
``` 
Should be changed to 
```
Std.is(1, Int)
```

###6.Haxe doesn't support lower case imports like this:
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

###7.Convert Vector to Array

Replace Vector with Array
```as3
Vector.<Sprite>
```   
To
```
Array<Sprite>
```

###8.Change Vector arrays initializations to Array
AS3 code like this:
```as3
var a:Vector.<MyClass> = new <MyClass> [new MyClass()];
```	
To
```
var a:Array<MyClass> = new Array<MyClass>();
a.push(new MyClass());
```

###9.Replace those dynamic params
```as3
function test (...params):void {
}
```
Change to:
```
function test (params:Array<Dynamic>) {
}
```   
 
###10.Final vars should be replaced with this tag 
```
@:final
```  
   
###11.Events meta tags like this
 
AS3:
```as3
[Event(name="test",type="Foo")]
```
To:
```
@:meta(Event(name="test",type="Foo"))
```
And should be checked other things and changed like in this article.
http://www.nme.io/developer/guides/actionscript-developers/

Credits
-------
Original code can be found here: 
http://pastebin.com/s0VccheL