package;

import flixel.FlxSprite;

class LevelGoal extends FlxSprite
{
	public var unlocks : String;

	public function new(X : Int, Y : Int, ?Frame : Int, ?Unlocks : String)
	{
		super(X, Y);

		if (Frame == null)
			Frame = 0;

		loadGraphic("assets/images/level-goal.png", true, 24, 24);
		animation.add("idle", [Frame]);
		animation.play("idle");

		setSize(14, 11);
		offset.set(5, 13);
		x = x+5;
		y = y+13;
		
		unlocks = Unlocks;
	}
}