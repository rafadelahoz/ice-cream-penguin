package;

import flixel.FlxObject;
import flixel.util.FlxTimer;

class EnemyHopper extends Enemy
{
	var idleTime : Float = 1;

	var jumps : Int = 0;
	var bigJumpAfter : Int = 3;
	
	var hspeed : Float = 60;
	var hopSpeed : Float = 80;
	var jumpSpeed : Float = 200;

	var timer : FlxTimer;
	
	var jumped : Bool;

	public function new(X : Float = 0, Y : Float = 0, World : PlayState = null)
	{
		super(X, Y, World);
		
		brain = new StateMachine(null, onStateChange);
		timer = new FlxTimer();
	}

	override public function init(?Category : Int, ?Variation : Int) : Void
	{
		super.init(Category, Variation);
		
		hazardType = Hazard.HazardType.Dirt;
		
		makeGraphic(16, 16, 0xFF0F5738);
		
		if (player.getMidpoint().x < getMidpoint().x)
			facing = FlxObject.LEFT;
		else
			facing = FlxObject.RIGHT;
		
		brain.transition(wait, "wait");
	}
	
	override public function freeze() : Void
	{
		super.freeze();
		timer.active = false;
	}

	override public function resume() : Void
	{
		super.resume();
		timer.active = true;
	}
	
	public function wait()
	{
		// Fall
		acceleration.y = GameConstants.Gravity;
	}
	
	public function jump()
	{
		// Fall
		acceleration.y = GameConstants.Gravity;
	
		if (!jumped)
		{
			if (jumps >= bigJumpAfter) 
			{
				velocity.y = -jumpSpeed;
				jumps = 0;
			}
			else
			{
				velocity.y = -hopSpeed;
			}
			
			jumped = true;
		}
	
		// When jumping
		if (velocity.y != 0)
		{
			// Move horizontally
			velocity.x = hspeed * (facing == FlxObject.LEFT ? -1 : 1);
			
			// Turn when touching walls
			if (justTouched(FlxObject.RIGHT) || justTouched(FlxObject.LEFT))
			{
				if (facing == FlxObject.LEFT)
					facing = FlxObject.RIGHT;
				else if (facing == FlxObject.RIGHT)
					facing = FlxObject.LEFT;
			}
		}
		else
		{
			velocity.x = 0;
		}
		
		if (justTouched(FlxObject.DOWN))
			brain.transition(wait, "wait");
	}
	
	public function onStateChange(newState : String) : Void
	{
		/*display.x = x;
		display.y = y;
		display.text = newState;*/
	
		switch (newState)
		{
			case "wait": 
				timer.start(idleTime, function(_timer : FlxTimer) {
					brain.transition(jump, "jump");
				});
			case "jump":
				jumps++;
				jumped = false;
		}
	}
	
	override public function onCollisionWithPlayer(penguin : Penguin)
	{
		if (penguin.getMidpoint().y > getMidpoint().y) 
		{
			// Bounce on penguin
			// velocity.x = hspeed * (facing == FlxObject.LEFT ? -1 : 1);
			// velocity.y = -hopSpeed;
			brain.transition(jump, "jump");
		}
	
		super.onCollisionWithPlayer(penguin);
	}
}