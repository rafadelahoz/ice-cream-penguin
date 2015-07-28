package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.util.FlxRandom;

class EnemyWalkShooter extends Enemy
{
	var hspeed : Float = 12;
	var bounceJumpSpeed : Float = 80;
	var attackProbability : Float = 0.5;
	var attackDelayTime : Float = 1;
	
	var shooter : ShooterComponent;
	var bouncing : Bool;
	var turning : Bool;
	var timer : FlxTimer;
	var alreadyDecided : Bool;
	
	var state : String;

	public function new(X : Int, Y : Int, World : PlayState)
	{	
		super(X, Y, World);
		
		type = "Walker";
		hazardType = Hazard.HazardType.Fire;
		
		loadGraphic("assets/images/fire_walker.png", true, 24, 24);
		centerOrigin();
		offset.set(4, 8);
		setSize(16, 16);

		animation.add("idle", [2, 3], 8, true);
		animation.add("walk", [0, 1, 2, 3, 4, 5, 2, 3], 8, true);
		animation.add("fall", [12, 13, 14], 8, true);
		animation.add("turn", [7, 8, 9, 10, 11], 17, false);
		
		color = 0xFF1040DD;
	
		if (world.penguin.getMidpoint().x < getMidpoint().x)
			facing = FlxObject.LEFT;
		else
			facing = FlxObject.RIGHT;
	
		alreadyDecided = false;
		timer = new FlxTimer();
		
		shooter = new ShooterComponent();
		shooter.init(world, Hazard.HazardType.Fire, 5);
	
		brain = new StateMachine(null, onStateChange);
		brain.transition(walk, "walk");
		
		FlxG.watch.add(this, "state");
	}
	
	override public function destroy() : Void
	{
		timer.destroy();
		shooter.destroy();
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
			timer.active = true;
			endTurning();
		}
	}
	
	public function attack() : Void
	{
		animation.play("fall");
		velocity.x = 0;
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
				timer.start(0.5, 
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
		if (nextState == "walk")
		{
			if (!alreadyDecided) 
			{
				// Decide whether to idle or shoot after a while
				doDecide();
			}
		}
		else if (nextState == "turn")
		{
			// If you have to start turning
			// Wait a little before doing it
			turning = false;
			animation.play("walk");
			// Actually turn after some while
			timer.start(0.5, 
				function preTurnTimer(timer : FlxTimer)
				{
					// Start turning
					turning = true;
					// Playing the turn animation
					animation.play("turn");
				});	
		}
		else if (nextState == "attack")
		{
			var tempAttackAnimDuration : Float = 0.85;
			timer.start(tempAttackAnimDuration, function (t : FlxTimer) : Void
				{
					shooter.shoot(getMidpoint(), player.getMidpoint());
					brain.transition(walk, "walk");
				});
		}
		
		state = nextState;
	}
	
	public function doDecide() : Void
	{
		alreadyDecided = true;
	
		if (FlxRandom.chanceRoll(attackProbability * 100))
		{
			trace("decided to attack");
			timer.start(attackDelayTime, 
				function(theTimer : FlxTimer):Void {
					trace("attacking");
					alreadyDecided = false;
					brain.transition(attack, "attack");
				});
		} else {
			trace("decided to walk");
			timer.start(attackDelayTime, 
				function(theTimer : FlxTimer):Void {
					trace("walking");
					alreadyDecided = false;
					brain.transition(walk, "walk");
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
		timer.start(0.5, 
			function postTurnTimer(timer : FlxTimer)
			{
				brain.transition(walk, "walk");					
			});
	}
	
	override public function onCollisionWithPlayer(aPlayer : Penguin) : Void
	{
		bounce();
	}
	
	override public function onCollisionWithIcecream(icecream : Icecream) 
	{
		if (hazardType == Hazard.HazardType.Fire)
		{
			// Melt icecream
			icecream.makeHotter(10);
		}
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