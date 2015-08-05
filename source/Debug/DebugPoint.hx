package;

import flixel.FlxSprite;
import flixel.util.FlxTimer;

/*
	// Sample usage:
	PlayFlowManager.get().world.add(new DebugPoint(Std.int(topleft.x), Std.int(topleft.y)));
	PlayFlowManager.get().world.add(new DebugPoint(Std.int(botright.x), Std.int(botright.y)));
*/

class DebugPoint extends FlxSprite
{
	public function new(X : Int, Y : Int)
	{
		super(X, Y);
		makeGraphic(2, 2, 0xFFFF00FF);
		new FlxTimer(0.01, function(timer:FlxTimer){kill();});
	}
}