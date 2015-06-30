package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxPoint;
import flixel.ui.FlxVirtualPad;

class Penguin extends FlxSprite
{
	public static var virtualPad : FlxVirtualPad;

	var world : PlayState;

	var icecream : FlxSprite;

	var gravity : Int = 900;
	var hspeed : Int = 90;
	var jumpSpeed : Int = 200;

	var carryPos : Int;
	var carryAnim = ["side", "top"];

	var icecreamOffset : Map <Int, Map<Int, FlxPoint>>;

	public function new(X:Int, Y:Int, parent:PlayState)
	{
		super(X, Y);

		setupOffset();

		world = parent;

		// makeGraphic(18, 24, 0xFF0030CC);
		loadGraphic("assets/images/penguin.png", true, 40, 32);
		centerOrigin();
		offset.set(12, 13);
		setSize(16, 19);

		animation.add("idle", [0]);
		animation.add("walk", [1, 2, 3, 2], 12, true);
		animation.add("jump", [4]);
		animation.add("fall", [5]);

		acceleration.x = 0;
		acceleration.y = gravity;

		// icecream = new FlxSprite(x, y).makeGraphic(12, 12, 0xFFCCFFCC);
		icecream = new FlxSprite(x, y).loadGraphic("assets/images/icecream.png", true, 40, 32);
		// Side
		icecream.animation.add("idle-side", [0]);
		icecream.animation.add("walk-side", [1, 2, 3, 2]);
		icecream.animation.add("jump-side", [4]);
		icecream.animation.add("fall-side", [5]);
		// Top
		icecream.animation.add("idle-top", [6]);
		icecream.animation.add("walk-top", [7, 8, 9, 8]);
		icecream.animation.add("jump-top", [10]);
		icecream.animation.add("fall-top", [11]);
		// Size
		icecream.setSize(12, 12);

		carryPos = 0;

		virtualPad = new FlxVirtualPad(FULL, A_B);
		virtualPad.alpha = 0.5;
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

		if (FlxG.keys.anyJustPressed(["S", "X"]))
			carryPos = (carryPos + 1) % 2; 

		if (velocity.y == 0) 
		{
			if (FlxG.keys.anyPressed(["A", "Z"]))
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
			var aoffset : FlxPoint = offsetMap.get(facing);
			icecream.x = x + aoffset.x;
			icecream.y = y + aoffset.y;

			icecream.offset.x = offset.x + aoffset.x;
			icecream.offset.y = offset.y + aoffset.y;

			icecream.flipX = flipX;		

			icecream.animation.play(animation.name + "-" + carryAnim[carryPos], false, animation.frameIndex);
			
		}
	}

	override public function draw() : Void
	{
		super.draw();

		icecream.animation.frameIndex = animation.frameIndex + (carryPos * 6);
		icecream.animation.paused = true;
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
		sideOffset.set(FlxObject.LEFT, new FlxPoint(-10, 0));
		sideOffset.set(FlxObject.RIGHT, new FlxPoint(14, 0));
		icecreamOffset.set(0, sideOffset);

		var topOffset : Map<Int, FlxPoint> = new Map<Int, FlxPoint>();
		topOffset.set(FlxObject.LEFT, new FlxPoint(2, -12));
		topOffset.set(FlxObject.RIGHT, new FlxPoint(2, -12));
		icecreamOffset.set(1, topOffset);
	}

}