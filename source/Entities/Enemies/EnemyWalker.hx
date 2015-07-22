package;

import flixel.FlxObject;

class EnemyWalker extends Enemy
{
	var hspeed : Float = 32;

	var bouncing : Bool;
	var bounceJumpSpeed : Float = 80;

	public function new(X : Int, Y : Int, World : PlayState)
	{
		type = "Walker";
		
		super(X, Y, World);
		
		makeGraphic(16, 16, 0xDD0505);
	
		brain = new StateMachine();
		brain.transition(walk);
	}
	
	override public function update() : Void
	{		
		if (frozen)
			return;

		acceleration.y = GameConstants.Gravity;

		super.update();
	}
	
	public function walk() : Void
	{
		if (facing == FlxObject.RIGHT)
		{
			velocity.x = hspeed;
			flipX = true;
		}
		else
		{
			velocity.x = -hspeed;
			flipX = true;
		}
	}
	
	public function stunned() : Void
	{
		// animation.play("stunned");
		alpha = 0.3;
		
		flipX = velocity.x < 0;

		if (justTouched(FlxObject.DOWN))
		{
			bouncing = false;
			brain.transition(walk);
		}		
	}
	
	override public function onCollisionWithPlayer(aPlayer : Penguin) : Void
	{
		bounce();
	}

	public function bounce(duration : Float = 0.2, ?force : Bool = false)
	{
		if (bouncing && !force)
			return;

		if (velocity.x > 0)
			velocity.x = -hspeed;
		else
			velocity.x = hspeed;

		velocity.y = -bounceJumpSpeed * 1;

		bouncing = true;

		brain.transition(stunned, "stunned");
	}
}