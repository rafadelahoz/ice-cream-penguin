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
		
		collideWithLevel = true;
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
				loadGraphic("assets/images/falling-hazards.png", true, 13, 13);
				// Setup mask
				setSize(7, 7);
				offset.set(3, 3);
				// Setup anims
				animation.add("fall", [4]);	
				animation.add("splash", [5, 6, 7], 8, false);
				animated = true;
				
			case Hazard.HazardType.Water:
				loadGraphic("assets/images/falling-hazards.png", true, 13, 13);
				// Setup mask
				setSize(7, 7);
				offset.set(3, 3);
				// Setup anims
				animation.add("fall", [0]);
				animation.add("splash", [1, 2, 3], 8, false);
				animated = true;
				// Water drops shall not affect the penguin
				dangerous = false;
				
			case Hazard.HazardType.Dirt:
				loadGraphic("assets/images/falling-hazards.png", true, 13, 13);
				// Setup mask
				setSize(7, 7);
				offset.set(3, 3);
				// Setup anims
				animation.add("fall", [8]);
				animation.add("splash", [9, 10, 11], 8, false);
				animated = true;
				
			case Hazard.HazardType.Collision:
				loadGraphic("assets/images/droplet.png");
				color = 0xff101010;
				
			default:
				loadGraphic("assets/images/droplet.png");
				color = 0xff101010;
		}

		if (brain == null)
			brain = new StateMachine(null, onStateChange);
		
		velocity.set(0, 0);
		acceleration.set(0, 0);

		brain.transition(prepare, "prepare");
	}
	
	override public function kill() : Void
	{
		velocity.set(0, 0);
		acceleration.set(0, 0);
		super.kill();
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
		alpha = 1;

		animation.play("fall");

		// setSize(targetSize.x, targetSize.y);
		acceleration.y = GameConstants.Gravity;

		if (isTouching(FlxObject.ANY))
		{
			brain.transition(splash, "splash");
			// alive = false;
		}
	}

	public function splash() : Void
	{
		// animation.play("splash");

		acceleration.set(0, 0);
		velocity.set(0, 0);

		if (animation.finished)
			kill();

		/*if (alpha > 0)
		{
			alpha -= deltaSize;
			
			if (alpha <= 0)
			{
				alpha = 0;
				destroy();
			}
		}*/
	}

	public function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "prepare":
				// deltaSize = targetSize.x / prepareTime;
			case "fall":
			case "splash":
				animation.play("splash");
				solid = false;
				// deltaSize = 1.0 / fadeTime;
		}
	}
	
	override public function onCollisionWithPlayer(player : Penguin) : Bool
	{
		if (velocity.y != 0)
		{
			brain.transition(splash, "splash");
			// alive = false;
		}
		
		return false;
	}
	
	override public function onCollisionWithIcecream(icecream : Icecream)
	{
		if (velocity.y != 0 && icecream.getMidpoint().y > getMidpoint().y)
		{
			y = icecream.y - height;

			animation.play("splash", true, 1);

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