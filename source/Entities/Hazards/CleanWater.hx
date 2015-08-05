package;

import flixel.FlxSprite;

class CleanWater extends FlxSprite
{
	public function new(X : Int, Y : Int, Width : Int, Height: Int)
	{
		super(X, Y);
		
		makeGraphic(Width, Height, 0x440110CC);
		setSize(Width, Height);
		centerOrigin();
	}
}