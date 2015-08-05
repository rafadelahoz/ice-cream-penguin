package;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxTimer;

class Icecream extends FlxSprite {
	
	public static var MaxIce : Int = 100;
	public static var MaxDry : Int = 100;

	public var ice : Int;
	public var dry : Int;
	public var debugLabel : FlxText;

	public function new(X : Float = 0, Y : Float = 0) {
	
		super(X, Y);

		initGraphics();

		ice = MaxIce;
		dry = MaxDry;

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

	public function makeColder(ammount : Int) 
	{
		ice += ammount;
		if (ice > MaxIce)
			ice = MaxIce;
	}

	public function makeHotter(ammount : Int) 
	{
		ice -= ammount;
		if (ice <= 0)
		{
			ice = 0;
			PlayFlowManager.get().onDeath("hot");
		}
	}

	public function water(ammount : Int)
	{
		dry -= ammount;
		if (dry <= 0)
		{
			dry = 0;
			PlayFlowManager.get().onDeath("water");
		}
	}

	public function mud(ammount : Int)
	{
		PlayFlowManager.get().onDeath("dirty");
	}
	
	public function steal(thief : Entity) 
	{
		PlayFlowManager.get().onDeath("steal");
	}
	
	/**
	 * Checks whether the icecream is fully contained in the given FlxRect
	 * @param rect Rectangle to check with	 
	 * @return Whether the rectangle contains the icecream or not
	*/
	public function containedIn(rect : FlxRect) : Bool
	{
		var topleft : FlxPoint = new FlxPoint(x, y);
		var botright: FlxPoint = new FlxPoint(topleft.x + width, topleft.y + height);
		
		return rect.containsFlxPoint(topleft) && rect.containsFlxPoint(botright);
	}
}