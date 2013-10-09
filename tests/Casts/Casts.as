package com.example
{
	import flash.display.MovieClip;
	
	public class Casts extends MovieClip
	{
		public function Casts()
		{
			int(10.1);
			
			(int("100"));
			
			Number("10");
			
			String(100);
			
			var sprite:Sprite = Sprite(this);
			
			var sprite:Sprite = this as Sprite;
			
			if (this is MovieClip)
			{
			}

			var cTest:ConstructorTest = new ConstructorTest(0);
		}
	}

	public class ConstructorTest
	{
		public function ConstructorTest(num:int)
		{

		}
	}
}