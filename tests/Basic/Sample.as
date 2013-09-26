package com.cloudkid.tasks
{
	import flash.display.MovieClip;
	
	public class Sample extends MovieClip
	{
		public static const SOME_CONSTANT:String = "onItemAboutToLoad";

		protected var __someNumber:Number = 100;
		
		private var __data:*:
		
		public var __map:Vector.<int>;
		
		public var __isPlaying:Boolean = false;
		
		public function Sample(name:String, data:*=null)
		{
			super();
			this.name = name;
			__data = data;
		}
		
		public function get data(): *
		{
			return __data;
		}
	}
}
