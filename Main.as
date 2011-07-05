package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	/**
	 * ...
	 * @author Dan McKinnon
	 */
	public class Main extends Sprite 
	{
		private var music:FANSIMusic;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			music = new FANSIMusic();
			ExternalInterface.addCallback("play", music.play );
		}
		
	}
	
}