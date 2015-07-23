package;

import flixel.FlxSprite;
import flixel.text.FlxText;

class Icecream extends FlxSprite {
	
	public static var MaxIce : Float = 100.0;

	public var ice : Float;
	public var debugLabel : FlxText;

	public function new(X : Float = 0, Y : Float = 0) {
	
		super(X, Y);

		initGraphics();

		ice = MaxIce;

		debugLabel = new FlxText(x, y);
	}

	public function initGraphics() : Void
	{
		loadGraphic("assets/images/icecream.png", true, 40, 32);
		// Side
		animation.add("idle-side", [0]);
		animation.add("walk-side", [1, 2, 3, 2]);
		animation.add("jump-side", [4]);
		animation.add("fall-side", [5]);
		animation.add("hurt-side", [4, 4]);
		// Top
		animation.add("idle-top", [6]);
		animation.add("walk-top", [7, 8, 9, 8]);
		animation.add("jump-top", [10]);
		animation.add("fall-top", [11]);
		animation.add("hurt-top", [10, 10]);
		// Size
		setSize(12, 12);
	}

	public function render(frameIndex : Int, carryPos : Int) : Void
	{		
		animation.frameIndex = frameIndex + (carryPos * 6);
		animation.paused = true;
		
		debugLabel.setPosition(x, y);
		
		debugLabel.text = animation.frameIndex + " (" + frameIndex + " + " + carryPos + "*6)";
		
		debugLabel.update();
		debugLabel.draw();
	}

	public function onCollisionWithHazard(hazard : Hazard) : Void
	{
		
	}
	
	public function onCollisionWithEnemy(enemy : Enemy) : Void
	{
		
	}

	public function makeColder(ammount : Float) 
	{
		ice += ammount;
		if (ice > MaxIce)
			ice = MaxIce;
	}

	public function makeHotter(ammount : Float) 
	{
		ice -= ammount;
		if (ice < 0)
		{
			ice = 0;
			DeathManager.get().onDeath("hot");
		}
	}
	
	public function steal(thief : Entity) 
	{
		DeathManager.get().onDeath("steal");
	}
}