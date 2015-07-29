package map;

import flixel.FlxSprite;

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
	
		if (levelFile != null)
			color = 0xFFC15523;
		else
			color = 0xFFBBBBBB;
			
		makeGraphic(8, 8, color);
	}
}