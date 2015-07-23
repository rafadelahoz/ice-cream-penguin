package;

import flixel.FlxObject;
import flixel.util.FlxPoint;

class DropHazard extends Hazard 
{
	var brain : StateMachine;

	var targetSize : FlxPoint;
	var prepareTime : Float = 1.5;
	var fadeTime : Float = 0.5;

	var deltaSize : Float;

	public function new(X : Float, Y : Float, World : PlayState, Type : Hazard.HazardType, ?Size : FlxPoint)
	{
		super(X, Y, Type, World);

		switch (Type)
		{
			case None:
				color = 0x00000000;
				Size = new FlxPoint(0, 0);
			case Fire:
				color = 0xff881010;
			case Water:
				color = 0xff101088;
			case Dirt:
				color = 0xff108810;
			case Collision:
				color = 0xff101010;
		}

		if (Size != null)
			targetSize = Size;
		else
			targetSize = new FlxPoint(16, 16);

		brain = new StateMachine(null, onStateChange);
		brain.transition(prepare, "prepare");
	}

	override public function update() : Void
	{
		if (frozen)
			return;

		brain.update();
		super.update();
	}

	public function prepare() : Void
	{
		setSize(width + deltaSize, height + deltaSize);
		if (width >= targetSize.x || height >= targetSize.y)
		{
			setSize(targetSize.x, targetSize.y);
			brain.transition(fall, "fall");
		}
	}

	public function fall() : Void
	{
		velocity.y = GameConstants.Gravity;
		if (isTouching(FlxObject.DOWN))
			brain.transition(splash, "splash");
	}

	public function splash() : Void
	{
		if (alpha > 0)
		{
			alpha -= deltaSize;
			
			if (alpha <= 0)
			{
				alpha = 0;
				kill();
			}
		}
	}

	public function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "prepare":
				deltaSize = targetSize.x / prepareTime;
			case "fall":
			case "splash":
				deltaSize = 255 / fadeTime;
		}
	}
}