package;

import flixel.FlxObject;
import flixel.util.FlxRandom;
import flixel.util.FlxTimer;

class EnemyWalker extends Enemy
{
	var hspeed : Float = 24;

	var bouncing : Bool;
	var bounceJumpSpeed : Float = 80;

	public function new(X : Int, Y : Int, World : PlayState)
	{
		type = "Walker";
		
		super(X, Y, World);
		
		loadGraphic("assets/images/fire_walker.png", true, 24, 24);
		centerOrigin();
		offset.set(4, 8);
		setSize(16, 16);

		animation.add("walk", [0, 1, 2, 3, 4, 5, 2, 3], 12, true);
		animation.add("fall", [12, 13, 14], 12, true);
		animation.add("turn", [7, 8, 9, 10, 11], 20);
	
		if (world.penguin.getMidpoint().x < getMidpoint().x)
			facing = FlxObject.LEFT;
		else
			facing = FlxObject.RIGHT;
	
		brain = new StateMachine(null, onStateChange);
		brain.transition(walk, "walk");
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
		alpha = 1;
		
		if (facing == FlxObject.RIGHT)
		{
			velocity.x = hspeed;
			flipX = false;
		}
		else
		{
			velocity.x = -hspeed;
			flipX = true;
		}


		if (justTouched(FlxObject.RIGHT) || justTouched(FlxObject.LEFT))
			brain.transition(turn, "turn");
		
		if (velocity.y != 0) 
		{
			animation.play("fall");
			velocity.x *= 0.25;
		} else 
		{
			animation.play("walk");
		}
	}

	public function turn() : Void
	{
		velocity.x = 0;

		/*if (animation.finished)
		{
			doTurn();
			brain.transition(walk, "walk");
		} else {*/
			animation.play("turn");
		//}
	}
	
	public function stunned() : Void
	{
		// animation.play("stunned");
		animation.play("fall");
		
		alpha = 0.3;
		flipX = velocity.x < 0;

		if (justTouched(FlxObject.DOWN))
		{
			bouncing = false;
			
			// Face random direction
			if (FlxRandom.float() < 0.5)
				facing = FlxObject.LEFT;
			else
				facing = FlxObject.RIGHT;
				
			brain.transition(walk, "walk");
		}		
	}

	public function onStateChange(nextState : String) : Void
	{
		if (nextState == "turn")
		{
			if (facing == FlxObject.RIGHT)
				x--;
			else
				x++;

			new FlxTimer(0.25, function turnTimer(timer : FlxTimer)
				{
					doTurn();
					animation.play("turn");
					if (facing == FlxObject.RIGHT)
						x++;
					else
						x--;

					brain.transition(walk, "walk");
				});
		}
	}

	public function doTurn() : Void
	{
		if (facing == FlxObject.LEFT)
			facing = FlxObject.RIGHT;
		else
			facing = FlxObject.LEFT;
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