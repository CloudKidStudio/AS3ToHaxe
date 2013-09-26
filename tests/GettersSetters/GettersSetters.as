package com.example
{
	public class GettersSetters
	{
		public function get data(): *
		{
			return __data;
		}

		public function set data(data:*): void
		{
			__data = data;
		}

		public function get name(): String
		{
			return __name;
		}

		public function set id(id:int): void
		{
			__id = id;
		}
	}
}	