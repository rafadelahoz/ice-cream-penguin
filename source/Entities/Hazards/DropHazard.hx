package;

import flixel.FlxObject;
import flixel.util.FlxPoint;

class DropHazard extends Hazard 
{
	var brain : StateMachine;

	var targetSize : FlxPoint;
	var prepareTime : Float = 1.5;
	var fadeTime : Float = 1;

	var animated : Bool;

	var deltaSize : Float;

	public function new(X : Float, Y : Float, World : PlayState, Type : Hazard.HazardType, ?Size : FlxPoint)
	{
		super(X, Y, Type, World);

		// makeGraphic(8, 8, color);
		// loadGraphic("assets/images/droplet.png");
		
		collideWithLevel = false;
	}
	
	public function init(X : Float, Y : Float, Type : Hazard.HazardType) : Void
	{
		x = X;
		y = Y;
		
		switch (Type)
		{
			case Hazard.HazardType.None:
				loadGraphic("assets/images/droplet.png");
				color = 0xffff00ff;
				
			case Hazard.HazardType.Fire:
				loadGraphic("assets/images/lava-drop.png", true, 16, 16);
				// Setup mask
				setSize(8, 8);
				offset.set(4, 5);
				// Setup anims
				animation.add("fall", [0, 1, 2, 3, 4, 5, 6, 7], 14);				
				animated = true;
				
			case Hazard.HazardType.Water:
				loadGraphic("assets/images/water-drop.png", true, 16, 16);
				// Setup mask
				setSize(8, 8);
				offset.set(4, 5);
				// Setup anims
				animation.add("fall", [0, 1, 2, 3, 4], 14);
				animated = true;
				// Water drops shall not affect the penguin
				dangerous = false;
				
			case Hazard.HazardType.Dirt:
				loadGraphic("assets/images/droplet.png");
				color = 0xff108810;
				
			case Hazard.HazardType.Collision:
				loadGraphic("assets/images/droplet.png");
				color = 0xff101010;
				
			default:
				loadGraphic("assets/images/droplet.png");
				color = 0xff101010;
		}

		if (brain == null)
			brain = new StateMachine(null, onStateChange);
		
		brain.transition(prepare, "prepare");
	}
	
	override public function destroy() : Void
	{
		velocity.set(0, 0);
		acceleration.set(0, 0);
		kill();
	}

	override public function update() : Void
	{
		if (frozen)
		{
			acceleration.set(0, 0);
			velocity.set(0, 0);
			return;
		}

		brain.update();		
		
		super.update();
	}

	public function prepare() : Void
	{
		brain.transition(fall, "fall");
	}

	public function fall() : Void
	{
		collideWithLevel = true;
		
		alpha = 1;

		animation.play("fall");

		// setSize(targetSize.x, targetSize.y);
		acceleration.y = GameConstants.Gravity;
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
				destroy();
			}
		}
	}

	public function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "prepare":
				// deltaSize = targetSize.x / prepareTime;
			case "fall":
			case "splash":
				deltaSize = 1.0 / fadeTime;
		}
	}
	
	override public function onCollisionWithPlayer(player : Penguin)
	{
		if (velocity.y != 0)
		{
			brain.transition(splash, "splash");
			alive = false;
		}
	}
	
	override public function onCollisionWithIcecream(icecream : Icecream)
	{
		if (velocity.y != 0)
		{
			switch (type)
			{
				case Hazard.HazardType.Fire:
					icecream.makeHotter(100);
				case Hazard.HazardType.Water:
					icecream.water(100);
				case Hazard.HazardType.Dirt:
					icecream.mud(100);
				default:
			}
			
			brain.transition(splash, "splash");
		}
	}
}