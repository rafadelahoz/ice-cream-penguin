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
		animation.add("hurt-side", [6, 7]);
		// Top
		animation.add("idle-top", [8]);
		animation.add("walk-top", [9, 10, 11, 10]);
		animation.add("jump-top", [12]);
		animation.add("fall-top", [13]);
		animation.add("hurt-top", [14, 15]);
		// Size
		setSize(12, 10);
		offset.y = 2;
	}

	public function render(frameIndex : Int, carryPos : Int) : Void
	{		
		animation.frameIndex = frameIndex + (carryPos * 8);
		animation.paused = true;
		
		debugLabel.setPosition(x, y);
		
		// debugLabel.text = animation.frameIndex + " (" + frameIndex + " + " + carryPos + "*6)";
		
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
		if (ice <= 0)
		{
			ice = 0;
			DeathManager.get().onDeath("hot");
		}
	}

	public function water(ammount : Float)
	{
		ice -= ammount;
		if (ice <= 0)
		{
			ice = 0;
			DeathManager.get().onDeath("water");
		}
	}

	public function mud(ammount : Float)
	{
		DeathManager.get().onDeath("dirty");
	}
	
	public function steal(thief : Entity) 
	{
		DeathManager.get().onDeath("steal");
	}
}