package com.cloudkid.tasks;

import flash.display.MovieClip;

import flash.Vector;

class Sample extends MovieClip
{
	public static inline var SOME_CONSTANT:String = "onItemAboutToLoad";

	private var __someNumber:Float = 100;
	
	private var __data:Dynamic:
	
	public var __map:Vector<Int>;
	
	public var __isPlaying:Bool = false;
	
	public function new(name:String, data:Dynamic=null)
	{
		super();
		this.name = name;
		__data = data;
	}
	
	public var data(getData, null):Dynamic;
 	private function getData(): Dynamic
	{
		return __data;
	}
}