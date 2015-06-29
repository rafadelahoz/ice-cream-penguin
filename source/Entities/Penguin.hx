package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxPoint;

class Penguin extends FlxSprite
{
	var world : PlayState;

	var icecream : FlxSprite;

	var gravity : Int = 900;
	var hspeed : Int = 90;
	var jumpSpeed : Int = 200;

	var carryPos : Int;

	var icecreamOffset : Map <Int, Map<Int, FlxPoint>>;

	public function new(X:Int, Y:Int, parent:PlayState)
	{
		super(X, Y);

		setupOffset();

		world = parent;

		// makeGraphic(18, 24, 0xFF0030CC);
		loadGraphic("assets/images/penguin-icecream.png", true, 40, 32);
		centerOrigin();
		offset.set(12, 13);
		setSize(16, 19);

		animation.add("idle", [0]);
		animation.add("walk", [1, 2, 3, 2], 12, true);
		animation.add("jump", [4]);
		animation.add("fall", [5]);

		acceleration.x = 0;
		acceleration.y = gravity;

		icecream = new FlxSprite(x, y).makeGraphic(12, 12, 0xFFCCFFCC);

		carryPos = 0;
	}

	override public function update() : Void
	{

		if (FlxG.keys.anyPressed(["LEFT"]))
		{
			facing = FlxObject.LEFT;
			flipX = true;
			velocity.x = -hspeed;
			animation.play("walk"); 
		}
		else if (FlxG.keys.anyPressed(["RIGHT"]))
		{
			facing = FlxObject.RIGHT;
			flipX = false;
			velocity.x = hspeed;
			animation.play("walk"); 
		}
		else 
		{
			velocity.x = 0;
			animation.play("idle"); 
		}

		if (FlxG.keys.anyJustPressed(["S"]))
			carryPos = (carryPos + 1) % 2; 

		if (velocity.y == 0) 
		{
			if (FlxG.keys.anyPressed(["Z"]))
			{
				velocity.y = -jumpSpeed;
			}
		} 
		else
		{
			if (velocity.y < 0)
				animation.play("jump");
			else
				animation.play("fall");
		}

		super.update();

		if (icecream != null)
		{
			var offsetMap : Map<Int, FlxPoint> = icecreamOffset.get(carryPos);
			var offset : FlxPoint = offsetMap.get(facing);
			icecream.x = x + offset.x;
			icecream.y = y + offset.y;
		}
	}

	override public function destroy() : Void
	{

	}

	public function getIcecream() : FlxSprite
	{
		return icecream;
	}

	private function setupOffset()
	{
		icecreamOffset = new Map<Int, Map<Int, FlxPoint>>();
		var sideOffset : Map<Int, FlxPoint> = new Map<Int, FlxPoint>();
		sideOffset.set(FlxObject.LEFT, new FlxPoint(-8, 0));
		sideOffset.set(FlxObject.RIGHT, new FlxPoint(12, 0));
		icecreamOffset.set(0, sideOffset);
		var topOffset : Map<Int, FlxPoint> = new Map<Int, FlxPoint>();
		topOffset.set(FlxObject.LEFT, new FlxPoint(-2, -4));
		topOffset.set(FlxObject.RIGHT, new FlxPoint(4, -4));
		icecreamOffset.set(1, topOffset);
	}

}