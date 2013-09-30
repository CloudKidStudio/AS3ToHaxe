package com.example
{
	public class GettersSetters
	{
		public function get data(): *
		{
			return __data;
		}

		public function get position(): String
		{
			return __position;
		}

		public function set id(id:int): void
		{
			__id = id;
		}
		
		public function set data(data:*): void
		{
			__data = data;
		}
	}
}	