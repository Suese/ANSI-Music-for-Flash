package  
{
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	/**
	 * ...
	 * @author ...
	 */
	public class FANSIMusic 
	{
		

		private const notes:Array = [65, 69, 73, 78, 82, 87, 92, 98, 104, 110, 116, 123, 131, 139, 147 , 156 , 165, 175 , 185, 196, 208, 220 , 233, 247 , 262, 278, 294, 312, 330, 350, 370, 392, 416, 440, 466, 494, 524, 556, 588, 624, 660, 700, 740, 784, 832, 880, 932, 988, 1048, 1112, 1176, 1248, 1320, 1400, 1480, 1568, 1664, 1760, 1864, 1976, 2096, 2224, 2352, 2496, 2640, 2800, 2960, 3136, 3328, 3520, 3728, 3952, 4192, 4448, 4704, 4992, 5280, 5600, 5920, 6272, 6656, 7040, 7456, 7904];
		private const mode_length:Array = [ 7 / 8, 1, 2 / 3 ];		
		
		public var volume:Number = 0.15;		
		private var last_repeat_string:String;
		private var channel:Array;
		
		private var sound:Sound;
		
		public function FANSIMusic() {
			//MB,MF,MS
			channel = [ new FANSIMusicChannel(), new FANSIMusicChannel(), new FANSIMusicChannel()];
			sound = new Sound();
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, sample_callback);
			sound.play();
			channel[0].volume = 0.25;
			channel[1].volume = 0.25;
			channel[2].volume = 0.50;
		}
		
		private function add_note( n:Number, note_length:Number, length_modifier:Number, tempo:Number, mode:Number,channel:FANSIMusicChannel,is_letter:Boolean):void {
			if (( n > 0 ) || (( n == 0) && is_letter) ){
				var final_length:Number = (1 / note_length) * mode_length[mode] * length_modifier;
				var pause_length:Number = (1 / note_length) * (1 - mode_length[mode]);
				
				
				
				//bmp
				final_length *= 240 / tempo;
				pause_length *= 240 / tempo;
				if ( final_length > 0 ) {
					channel.append([final_length, notes[n ]]);
				}
				
				if ( pause_length > 0 ) {
					channel.append([pause_length, 0]);
				}
			//lowest letter referenced by number is just a pause
			} else if ( n == 0 ) {
				channel.append([(1 / note_length) * (240 / tempo), 0]);
			}
		}
		private function add_pause( length:Number, tempo:Number,channel:FANSIMusicChannel):void {
			var pause_length:Number = ( 1 / length ) * (240 / tempo);
			channel.append([pause_length, 0]);
		}		
		public function play(instr:String):void {
			var str:String = instr.toUpperCase();
			var has_mb:Boolean = str.indexOf("MB") >= 0;
			var has_mf:Boolean = str.indexOf("MF") >= 0;
			var has_mx:Boolean = str.indexOf("MX") >= 0;
			var has_repeat:Boolean = !has_mx && (str.indexOf("R") >= 0);
			
			//clear effected channels
			if ( str.length == 0) {
				channel[0].clear();
				channel[1].clear();
				channel[2].clear();
			}

			if ( !has_repeat || (has_repeat && (str != last_repeat_string ))) {
				if ( !has_mx ){
					channel[0].clear();
					channel[1].clear();
				}				
			}
			
			if ( has_mx ) {
				channel[2].clear();
			}
			
			//don't even both interpreting it if it's the same as the previous repeat string
			if ( has_repeat && (str == last_repeat_string ) ) {				
				return;
			}
			
			if ( has_repeat) {
				last_repeat_string = str;
			}				
				

			
			//Octave and tone commands:
			//Ooctave    Sets the current octave (0 - 6).
			//< or >     Moves up or down one octave.
			//A - G      Plays the specified note in the current octave.
			//Nnote      Plays a specified note (0 - 83) in the seven-octave
			//			 range (0 is a rest).
			//
			//Duration and tempo commands:
			//Llength    Sets the length of each note (1 - 64). L1 is whole note,
			//L2 is a half note, etc.
			//ML         Sets music legato.
			//MN         Sets music normal.

			//MS         Sets music staccato.
			//Ppause     Specifies a pause (1 - 64). P1 is a whole-note pause,
			//P2 is a half-note pause, etc.
			//Ttempo     Sets the tempo in quarter notes per minute (32 - 255).
			//
			//Mode commands:
			//MF          Plays music in foreground channel
			//MB          Plays music in background channel
			//MX          Plays music in SFX channel
			//
			//Suffix commands:
			//# or +      Turns preceding note into a sharp.
			//-           Turns preceding note into a flat.
			//.           Plays the preceding note 3/2 as long as specified.
			//
			var octave:Number = 2;
			var tempo:Number = 120;
			var mode:Number = 0;		//0 - normal, 1 - legatto, 2 - stacatto
			var note_length:Number = 4;
			var current_note:Number = -1;
			var n:String;
			var t:Number;
			var j:int;
			var length_modifier:Number = 1;
			var ch:FANSIMusicChannel = channel[1];
			
			var final_length:Number;
			var pause_length:Number;
			var is_letter:Boolean = false;
			
			for ( var i:int = 0; i < str.length; ) {
				switch ( str.charAt(i) ) {
					case "#":
					case "+":
						current_note += ((current_note < notes.length-1) && (current_note > -1) ) ? 1 : 0;
					break;
					case "-":
						current_note -= (current_note > 0)  ? 1 : 0;
					break;
					case ".":
						length_modifier = 3/2;
					break;
					default:
						//commit previous note
						add_note(current_note, note_length, length_modifier, tempo, mode,ch,is_letter);						
						length_modifier = 1;							
						current_note = -1;
						
					break;
				}
				switch( str.charAt(i++) ) {
					//select octave
					case "O":
						if ( i < str.length) {
							n = "";
							for ( j = 0; (i < str.length) && (str.charCodeAt(i) >= 48) && (str.charCodeAt(i) <= 57); j++) {								
								n += str.charAt(i++);
							}
							t = new Number(n);						
							if (( t >= 0) && ( t <= 6) ) {
								octave = t;
							}
						}
					break;
					//octave up
					case "<":
						octave -= (octave > 0 ) ? 1 : 0;
					break;
					//octave down
					case ">":
						octave += (octave < 6) ? 1 : 0;
					break;
					
					//play note
					case "N":
						if ( i < str.length) {
							n = "";
							for ( j = 0; (i < str.length) && (str.charCodeAt(i) >= 48) && (str.charCodeAt(i) <= 57); j++) {								
								n += str.charAt(i++);
							}
							t = new Number(n);						
							if (( t >= 0) && ( t <= 84) ) {
								current_note = t;
								is_letter = false;
							}
						}						
					break;
					
					//play specific note
					case "A":
						current_note = (octave * 12) + 9;
						is_letter = true;
					break;
					case "B":
						current_note = (octave * 12) + 11;
						is_letter = true;
					break;
					case "C":
						current_note = (octave * 12) + 0;
						is_letter = true;
					break;
					case "D":
						current_note = (octave * 12) + 2;
						is_letter = true;
					break;
					case "E":
						current_note = (octave * 12) + 4;
						is_letter = true;
					break;
					case "F":
						current_note = (octave * 12) + 5;
						is_letter = true;
					break;
					case "G":
						current_note = (octave * 12) + 7;
						is_letter = true;
					break;
					

					//Note Length
					case "L":
						if ( i < str.length) {
							n = "";
							for ( j = 0; (i < str.length) && (str.charCodeAt(i) >= 48) && (str.charCodeAt(i) <= 57); j++) {								
								n += str.charAt(i++);
							}
							t = new Number(n);						
							if (( t >= 1) && ( t <= 64) ) {
								note_length = t;
							}
						}
					break;
					case "P":
						if ( i < str.length) {
							n = "";
							for ( j = 0; (i < str.length) && (str.charCodeAt(i) >= 48) && (str.charCodeAt(i) <= 57); j++) {								
								n += str.charAt(i++);
							}
							t = new Number(n);						
							if (( t >= 1) && ( t <= 64) ) {								
								add_pause(t, tempo,ch);
							}
						}
					break;
					
					//Tempo
					case "T":
						if ( i < str.length) {
							n = "";
							for ( j = 0; (i < str.length) && (str.charCodeAt(i) >= 48) && (str.charCodeAt(i) <= 57); j++) {								
								n += str.charAt(i++);
							}
							t = new Number(n);						
							if (( t >= 32) && ( t < 256) ) {
								tempo = t;
							}
						}
					break;
					
					case "R":
						channel[0].repeat = true;
						channel[1].repeat = true;
					break;

					
					case "M":
						if ( i < str.length) {
							switch( str.charAt(i++) ) {
								case "L":
									mode = 1;
								break;
								case "N":
									mode = 0;
								break;
								case "S":
									mode = 2;
								break;
								case "F":
									ch = channel[1]
								break;
								case "B":
									ch = channel[0]
								break;
								case "X":
									ch = channel[2];
								break;
							}
						}
					break;
				}
				
			}			
			add_note(current_note, note_length, length_modifier, tempo, mode,ch,is_letter);						
			
			//start effected channels
			//search for MB,MF,and MS and
			if ( has_mb ) {
				channel[0].start();
			}
			if ( has_mf || (!has_mb && !has_mx && !has_mf) ) {
				channel[1].start();
			}
			if ( has_mx ) {
				channel[2].start();
			}		
			
		}
		
		private function next_sample(i:Number):Number {
			return (channel[0].next_sample(i) + channel[1].next_sample(i) + channel[2].next_sample(i)) * volume; 
		}
		private function sample_callback(e:SampleDataEvent):void {
			var s:Number = 0;
			for ( var i:Number = 0; i < 8192; i++ ) {
				s = next_sample(e.position + i);
				e.data.writeFloat(s);
				e.data.writeFloat(s);
			}
		}
		
		public function off():void {
			channel[0].clear();
			channel[1].clear();
			channel[2].clear();
			sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, sample_callback);
		}
		
		public function on():void {
			channel[0].clear();
			channel[1].clear();
			channel[2].clear();
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, sample_callback);
			sound.play();
		}
	}

}