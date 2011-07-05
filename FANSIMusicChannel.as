package  
{
	/**
	 * ...
	 * @author ...
	 */
	public class FANSIMusicChannel 
	{
		private const SAMPLING_RATE:int = 44100;
		private const TWO_PI:Number = 2*Math.PI;
		private const TWO_PI_OVER_SR:Number = TWO_PI / SAMPLING_RATE;
		
		public var repeat:Boolean = false;
		public var volume:Number = 0.30;
		private var frequency:Number = 0;
		private var samples_left:Number = 0;
		private var play_head:Number = 0;
		
		private var done:Boolean = true;
		private var module:Array = [];
		
		public function FANSIMusicChannel() {
			
		}
		
		
		public function start():void {
			if ( done ){
				if ( module.length > 1 ) {
					done = false;
					samples_left = module[play_head++] * SAMPLING_RATE;
					frequency = module[play_head++];
				} else {
					module = [];
					done = true;
				}				
			}
		}
		public function append(items:Array):void {
			module = module.concat(items);
		}
		public function clear():void {
			done = true;
			play_head = 0;
			repeat = false;
			module = [];
		}
		
		public function next_sample(i:Number):Number {
			var r:Number = 0;
			if ( !done ) {
				samples_left--;
				if ( samples_left <= 0 ) {
					
					//grab a new duration-frequency pair from the module
					if ( play_head <  module.length ) {
						samples_left = SAMPLING_RATE * module[play_head++];
						frequency = module[play_head++];
					} else {
						if ( repeat ) {
							play_head = 0;
						} else {
							done = true;
						}
					}
				}
				r = Math.sin(i * TWO_PI_OVER_SR * frequency) > 0 ? volume : -volume;	
			}
			return r;			
		}
		
	}

}