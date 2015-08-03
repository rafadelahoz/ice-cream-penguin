package;

import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

class EnemyRunner extends Enemy
{
	public var state : String;
	var display : FlxText;

	var alertStateTime : Float = 0.5;
	var jumpDelayTime : Float = 0.58;
	
	var alertedDistance : Int = 80;
	var hspeed : Int = 50;
	var jumpHspFactor : Float = 1.5;
	var jumpDistance : Int = 32;
	var jumpSpeed : Int = 125;
	var bounceSpeed : Int = 100;

	var jumper : Bool;
	var jumperJumpHspFactor : Float = 1.5;
	var jumperJumpDistance : Int = 36;
	var jumperJumpSpeed : Int = 200;	// For gravity = 650
	// var jumperJumpSpeed : Int = 250; // For gravity = 900

	var jumped : Bool;
	var timer : FlxTimer;
	var bouncing : Bool;
	var alreadyAlerted : Bool;
	var preparingJump : Bool;

	public function new(X : Int, Y : Int, World : PlayState, Jumper : Bool = false)
	{
		type = "Runner";
		jumper = Jumper;

		super(X, Y, World);
		if (!jumper)
			loadGraphic("assets/images/enemy-cat-cream.png", true, 24, 24);
		else
			loadGraphic("assets/images/enemy-cat-black.png", true, 24, 24);
		centerOrigin();
		offset.set(6, 12);
		setSize(12, 12);

		animation.add("idle", [0]);
		animation.add("run", [1, 2, 3, 0], 8, true);
		animation.add("jump", [1]);
		animation.add("fall", [2]);
		animation.add("stunned", [4]);
		animation.add("sleep", [5, 6], 1, true);
		animation.add("alert", [7]);

		brain = new StateMachine(null, onStateChange);
		brain.transition(sleep, "sleep");

		display = new FlxText(getMidpoint().x, getMidpoint().y - 8);
		/*display.scale.x = 0.25;	
		display.scale.y = 0.25;*/

		if (jumper)
		{
			jumpHspFactor = jumperJumpHspFactor;
			jumpSpeed = jumperJumpSpeed;
			jumpDistance = jumperJumpDistance;
		}
		
		timer = new FlxTimer();

		bouncing = false;
	}

	override public function draw() : Void
	{
		super.draw();
		display.draw();
	}

	override public function update() : Void
	{		
		if (!inWorldBounds())
		{
			destroy();
		}
	
		if (frozen)
			return;
			
		if (overlaps(world.watery))
		{
			if (state != "drown")
			{
				acceleration.y = GameConstants.Gravity * 0.1;
				velocity.x /= 3;
				brain.transition(drown, "drown");
			}
		}
		else
		{
			acceleration.y = GameConstants.Gravity;
		}

		super.update();

		display.text = state;
		display.x = x;
		display.y = y;
		display.update();
	}

	public function sleep() : Void
	{
		animation.play("sleep");

		if (distanceToPlayer() < alertedDistance)
			brain.transition(alert, "alert");
	}

	public function alert() : Void
	{
		if (!alreadyAlerted)
			animation.play("alert");
		else
			animation.play("idle");
	}

	public function onAlertTimer(timer : FlxTimer) : Void
	{
		if (state == "alert") 
		{
			brain.transition(chase, "chase");
			alreadyAlerted = true;
		}
		else if (state == "chase")
		{
			timer.cancel();
			brain.transition(jump, "jump");
			preparingJump = false;
		}
	}

	public function chase() : Void
	{
		if (preparingJump)
		{
			// Waiting to start chase!
			velocity.x = 0;
			animation.play("idle");
			return;
		}
		
		if (player.getPosition().x < x)
		{
			velocity.x = -hspeed;
			flipX = false;
		}
		else
		{
			velocity.x = hspeed;
			flipX = true;
		}

		if (distanceToPlayer() < jumpDistance && velocity.y == 0)
		{
			timer.start(jumpDelayTime, onAlertTimer);
			preparingJump = true;
			return;
		}

		if (velocity.y != 0)
			velocity.x *= 1.5;

		if (velocity.y < 0)
			animation.play("jump");
		else if (velocity.y > 0)
			animation.play("fall");
		else
			animation.play("run");
	}

	public function jump() : Void
	{
		if (!jumped)
		{
			jumped = true;
			velocity.y = -jumpSpeed;
			if (player.getPosition().x < x)
			{
				velocity.x = -hspeed;
				flipX = false;
			}
			else
			{
				velocity.x = hspeed;
				flipX = true;
			}
			velocity.x *= jumpHspFactor;
		}

		if (velocity.y < 0)
			animation.play("jump");
		else if (velocity.y > 0)
			animation.play("fall");

		if (justTouched(FlxObject.DOWN))
		{
			brain.transition(idle, "idle");
		}
	}

	public function stunned() : Void
	{
		animation.play("stunned");
		flipX = velocity.x < 0;

		if (justTouched(FlxObject.DOWN))
		{
			bouncing = false;
			brain.transition(idle, "idle");
		}		
	}

	public function idle() : Void
	{
		velocity.x = 0;

		if (velocity.y == 0)
			animation.play("idle");
		else
			animation.play("jump");

		if (distanceToPlayer() < alertedDistance)
		{
			brain.transition(alert, "alert");	
		}
	}
	
	public function drown() : Void
	{
		animation.play("stunned");
		timer.start(0.3, function(tmr : FlxTimer):Void { flipX = !flipX; }, 0);
	}

	public function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "idle":
			case "alert":
				timer.start(alertStateTime, onAlertTimer);
			case "chase":
				timer.cancel();
				velocity.y = -100;
				preparingJump = false;
			case "jump":
				jumped = false;
		}

		state = newState;
	}

	override public function onCollisionWithPlayer(aPlayer : Penguin) : Void
	{
		bounce();
	}
	
	override public function onCollisionWithIcecream(icecream : Icecream) 
	{
		if (state == "jump")
		{
			// Melt icecream
			icecream.steal(this);
		}
	}

	public function bounce(duration : Float = 0.2, ?force : Bool = false)
	{
		if (bouncing && !force)
			return;

		if (player.getMidpoint().x > getMidpoint().x)
			velocity.x = -hspeed;
		else
			velocity.x = hspeed;

		velocity.y = -bounceSpeed;

		bouncing = true;

		brain.transition(stunned, "stunned");
	}

	public function distanceToPlayer() : Float
	{
		return player.getPosition().distanceTo(getMidpoint());
	}
}