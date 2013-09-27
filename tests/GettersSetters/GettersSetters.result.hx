package com.example;

class GettersSetters
{
	public var data(get, set):Dynamic;
 	private function get_data(): Dynamic
	{
		return __data;
	}

	private function set_data(data:Dynamic): Void
	{
		__data = data;
	}

	public var name(get, set):String;
 	private function get_name(): String
	{
		return __name;
	}

	public var id(null, set):Int;
 	private function set_id(id:Int): Void
	{
		__id = id;
	}
}