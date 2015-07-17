package;

import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

class EnemyRunner extends Enemy
{
	public var state : String;
	var display : FlxText;

	var timer : FlxTimer;

	var bouncing : Bool;

	var hspeed : Int = 50;
	var jumpHspFactor : Float = 1.5;
	var jumpDistance : Int = 36;
	var jumpSpeed : Int = 100;
	var jumped : Bool;
	var alertedDistance : Int = 80;

	public function new(X : Int, Y : Int, World : PlayState)
	{
		type = "Runner";

		super(X, Y, World);
		loadGraphic("assets/images/enemy-cat-cream.png", true, 24, 24);
		centerOrigin();
		offset.set(6, 12);
		setSize(12, 12);

		animation.add("idle", [0]);
		animation.add("run", [1, 2, 3, 0], 4, true);
		animation.add("jump", [1]);
		animation.add("fall", [2]);
		animation.add("stunned", [4]);
		animation.add("sleep", [5, 6], 1, true);
		animation.add("alert", [7]);

		brain = new StateMachine(null, onStateChange);
		brain.transition(sleep, "sleep");

		display = new FlxText(getMidpoint().x, getMidpoint().y - 8);
		display.scale.x = 0.25;	
		display.scale.y = 0.25;

		bouncing = false;
	}

	override public function draw() : Void
	{
		super.draw();
		display.draw();
	}

	override public function update() : Void
	{		
		if (frozen)
			return;

		acceleration.y = GameConstants.Gravity;

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
		animation.play("alert");
	}

	public function onAlertTimer(timer : FlxTimer) : Void
	{
		trace("OnTimerAlert for State " + state);

		if (state == "alert") 
		{
			brain.transition(chase, "chase");
		}
		else if (state == "chase")
		{
			timer = null;
			brain.transition(jump, "jump");
		}
	}

	public function chase() : Void
	{
		if (timer != null) 
		{
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
			timer = new FlxTimer(0.2, onAlertTimer);
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
			brain.transition(alert, "alert");
	}

	public function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "idle":
			case "alert":
				timer = new FlxTimer(0.4, onAlertTimer);
			case "chase":
				timer = null;
				velocity.y = -100;
			case "jump":
				jumped = false;
		}

		state = newState;
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

		velocity.y = -jumpSpeed * 1;

		bouncing = true;

		brain.transition(stunned, "stunned");
	}

	public function distanceToPlayer() : Float
	{
		return player.getPosition().distanceTo(getMidpoint());
	}
}