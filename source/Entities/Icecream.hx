package;

import flixel.FlxSprite;

class Icecream extends FlxSprite {
	
	public function new(X : Float = 0, Y : Float = 0) {
	
		super(X, Y);

		init();

	}

	public function init() : Void
	{
		loadGraphic("assets/images/icecream.png", true, 40, 32);
		// Side
		animation.add("idle-side", [0]);
		animation.add("walk-side", [1, 2, 3, 2]);
		animation.add("jump-side", [4]);
		animation.add("fall-side", [5]);
		animation.add("hurt-side", [0, 0]);
		// Top
		animation.add("idle-top", [6]);
		animation.add("walk-top", [7, 8, 9, 8]);
		animation.add("jump-top", [10]);
		animation.add("fall-top", [11]);
		animation.add("hurt-top", [6, 6]);
		// Size
		setSize(12, 12);
	}

	public function render(frameIndex : Int, carryPos : Int) : Void
	{
		animation.frameIndex = frameIndex + (carryPos * 6);
		animation.paused = true;
	}

	public function onCollisionWithHazard(hazard : Hazard) : Void
	{
		
	}
}