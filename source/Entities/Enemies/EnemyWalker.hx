package;

import flixel.FlxObject;
import flixel.util.FlxRandom;
import flixel.util.FlxTimer;

class EnemyWalker extends Enemy
{
	var hspeed : Float = 24;

	var bouncing : Bool;
	var bounceJumpSpeed : Float = 80;
	var turning : Bool;

	public function new(X : Int, Y : Int, World : PlayState)
	{
		type = "Walker";
		
		super(X, Y, World);
		
		loadGraphic("assets/images/fire_walker.png", true, 24, 24);
		centerOrigin();
		offset.set(4, 8);
		setSize(16, 16);

		animation.add("idle", [2, 3], 12, true);
		animation.add("walk", [0, 1, 2, 3, 4, 5, 2, 3], 12, true);
		animation.add("fall", [12, 13, 14], 12, true);
		animation.add("turn", [7, 8, 9, 10, 11], 20, false);
	
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

		if (facing == FlxObject.LEFT)
			flipX = true;
		else
			flipX = false;
		
		if (turning && animation.finished)
		{
			endTurning();
		}
	}
	
	public function stunned() : Void
	{
		if (!bouncing)
			return;
			
		// Show your stunnement
		animation.play("fall");
		
		// Handle the flip thing
		flipX = velocity.x > 0;
		
		// Correctly face
		if (velocity.x < 0)
			facing = FlxObject.RIGHT;
		else
			facing = FlxObject.LEFT;

		// Reset when hit ground
		if (justTouched(FlxObject.DOWN))
		{
			// Not bouncing anymore
			bouncing = false;
			
			// So stop moving
			velocity.x = 0;
			velocity.y = 0;
			
			// Wait a little before starting to move
			// And maybe turn
			if (FlxRandom.float() < 0.5)
			{
				brain.transition(turn, "turn");
			}
			else
			{
				// Now wait a tad before starting to actually walk
				doTurn();
				animation.play("walk");
				new FlxTimer(0.5, 
					function postTurnTimer(timer : FlxTimer)
					{
						doTurn();
						brain.transition(walk, "walk");					
					});
			}
		}		
	}

	public function onStateChange(nextState : String) : Void
	{
		if (nextState == "turn")
		{
			// If you have to start turning
			// Wait a little before doing it
			turning = false;
			animation.play("walk");
			// Actually turn after some while
			new FlxTimer(0.5, 
				function preTurnTimer(timer : FlxTimer)
				{
					// Start turning
					turning = true;
					// Playing the turn animation
					animation.play("turn");
				});	
		}
	}

	public function doTurn() : Void
	{
		// Faces the opposite direction of the current one
		if (facing == FlxObject.LEFT)
			facing = FlxObject.RIGHT;
		else
			facing = FlxObject.LEFT;
	}
	
	public function endTurning() : Void
	{
		// You are not turning anymore
		turning = false;
		// Face the correct direction
		doTurn();
		// Start walking on place
		animation.play("walk", false, (facing == FlxObject.LEFT ? 2 : 0));
		// Now wait a tad before starting to actually walk
		new FlxTimer(0.5, 
			function postTurnTimer(timer : FlxTimer)
			{
				brain.transition(walk, "walk");					
			});
	}
	
	override public function onCollisionWithPlayer(aPlayer : Penguin) : Void
	{
		bounce();
	}

	public function bounce(duration : Float = 0.2, ?force : Bool = false)
	{
		if (bouncing && !force)
			return;

		if (player.getMidpoint().x < getMidpoint().x)
			velocity.x = hspeed;
		else
			velocity.x = -hspeed;

		velocity.y = -bounceJumpSpeed * 1;

		bouncing = true;

		brain.transition(stunned, "stunned");
	}
}