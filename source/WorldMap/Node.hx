package;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class Node extends FlxSprite
{
	public var name : String;
	public var levelFile : String;
	public var paths : Map<Int, Path>;
	
	public function new(X : Int, Y : Int, Name : String, ?LevelFile : String)
	{
		super(X, Y);
		
		name = Name;
		levelFile = LevelFile;
		paths = new Map<Int, Path>();
	
		var nodeColor : Int;
		if (levelFile != null)
			nodeColor = FlxColor.BLUE;
		else
			nodeColor = FlxColor.WHITE;
			
		makeGraphic(16, 16, nodeColor);		
	}
}