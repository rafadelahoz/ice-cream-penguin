package;

import flixel.FlxSprite;
import flixel.FlxG;

class Penguin extends FlxSprite
{
	var gravity : Int = 900;
	var hspeed : Int = 90;
	var jumpSpeed : Int = 200;

	public function new(X:Int, Y:Int)
	{
		super(X, Y);

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
	}

	override public function update() : Void
	{

		if (FlxG.keys.anyPressed(["LEFT"]))
		{
			flipX = true;
			velocity.x = -hspeed;
			animation.play("walk"); 
		}
		else if (FlxG.keys.anyPressed(["RIGHT"]))
		{
			flipX = false;
			velocity.x = hspeed;
			animation.play("walk"); 
		}
		else 
		{
			velocity.x = 0;
			animation.play("idle"); 
		}

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

	}

	override public function destroy() : Void
	{

	}

}