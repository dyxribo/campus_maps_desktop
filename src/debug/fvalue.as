package debug
{
	
	/**
	 * ...
	 * @author Psycho
	 */
	public class fvalue
	{
		static public function toFloat(n:Number):Number
		{
			return parseFloat(String(Math.round(n * 100) / 100));
		}
		
		static public function toOctal(n:Number):String
		{
			var retString:String = "";
			retString = n.toString(8);
			
			retString = retString + "0";
			
			return retString;
		}
		
		static public function toHex(n:Number):String
		{
			var retString:String = "";
			retString = n.toString(16).toUpperCase();
			
			while (retString.length < 6)
			{
				retString = "0" + retString;
			}
			
			return retString;
		}
		
		static public function toCharacter(s:String):String
		{
			return s.substr(0, 1);
		}
	}
}