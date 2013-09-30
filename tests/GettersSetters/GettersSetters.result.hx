package com.example;

class GettersSetters
{
	public var data(get, set):Dynamic;
 	private function get_data(): Dynamic
	{
		return __data;
	}

	public var position(get, never):String;
 	private function get_position(): String
	{
		return __position;
	}

	public var id(never, set):Int;
 	private function set_id(id:Int):Int
	{
		__id = id;
	}
	
	private function set_data(data:Dynamic):Dynamic
	{
		__data = data;
	}
}