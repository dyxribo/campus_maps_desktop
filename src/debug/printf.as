package debug
{
	/**
	 * Writes the string pointed by format to the standard output (flash debugger). If format includes format specifiers (subsequences beginning with %), the additional arguments following format are formatted and inserted in the resulting string replacing their respective specifiers.
	 * @author Psycho
	 * fireman.fg@gmail.com
	 */
	
	/**
	 *
	 * @param	format string that contains the text to be written to the flash debugger. It can optionally contain embedded format specifiers that are replaced by the values specified in subsequent additional arguments and formatted as requested.
	 * @param	rest additional args
	 */
	public function printf(format:String, ... rest):void
	{
		if (rest.length === 1 && rest[0] is Array) {
			rest = rest[0];
		}

		var specifiers:Array = format.match(/%[i|d|u|U|o|O|x|X|c|C|s|S|f|F|n|N|l|L|b|B|%]/g);
		var evaluate:Function = function(specifier:String, val:*):*
		{
			switch (specifier)
			{
			case "%i": 
			case "%d": 
				return int(val);
			case "%u": 
			case "%U": 
				return uint(val);
			case "%o": 
				return fvalue.toOctal(val);
			case "%O": 
				return fvalue.toOctal(val).toUpperCase();
			case "%x": 
				return fvalue.toHex(val);
			case "%X": 
				return fvalue.toHex(val).toUpperCase();
			case "%c": 
				return fvalue.toCharacter(val);
			case "%C": 
				return fvalue.toCharacter(val).toUpperCase();
			case "%s": 
				return String(val);
			case "%S": 
				return String(val).toUpperCase();
			case "%n": 
			case "%N": 
				return (val as Number);
			case "%l": 
			case "%L": 
				return fvalue.toFloat(val);
			case "%b": 
				return val;
			case "%B": 
				return (val) ? "TRUE" : "FALSE";
			case "%%": 
				return "%";
			default: 
				return "<invalid specifier>";
			}
		};
		
		for (var i:int = 0; i < specifiers.length; i++)
		{
			format = format.replace(specifiers[i], evaluate(specifiers[i], rest[i]));
			if (specifiers[i] == "%%") rest.unshift("");
		}
		trace(format);
	}

}