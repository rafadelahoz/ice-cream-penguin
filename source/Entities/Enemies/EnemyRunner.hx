package;

import flixel.util.FlxTimer;

class EnemyRunner extends Enemy
{
	public var state : String;

	var timer : FlxTimer;

	var hspeed : Int = 60;
	var jumpDistance : Int = 40;
	var alertedDistance : Int = 60;

	public function new(X : Int, Y : Int, World : PlayState)
	{
		super(X, Y, World);
		loadGraphic("assets/images/enemy-cat-cream.png", true, 24, 24);
		centerOrigin();
		offset.set(4, 9);
		setSize(16, 15);

		animation.add("idle", [0]);
		animation.add("run", [1, 2, 3, 0], 8, true);
		animation.add("jump", [1]);
		animation.add("fall", [2]);
		animation.add("hurt", [4]);
		animation.add("sleep", [5, 6], 4, true);
		animation.add("alert", [7]);

		brain = new StateMachine(sleep, onStateChange);
	}

	override public function update() : Void
	{		
		acceleration.y = GameConstants.Gravity;

		super.update();
	}

	public function sleep() : Void
	{
		animation.play("sleep");

		trace(distanceToPlayer());

		if (distanceToPlayer() < alertedDistance)
			brain.transition(alert, "alert");
	}

	public function alert() : Void
	{
		animation.play("alert");
	}

	public function onAlertTimer(timer : FlxTimer) : Void
	{
		trace("OnAlertTimer!");
		if (state == "alert") 
		{
			brain.transition(chase, "chase");
		}
	}

	public function chase() : Void
	{
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
			velocity.y = -150;
		}

		if (velocity.y < 0)
			animation.play("jump");
		else if (velocity.y > 0)
			animation.play("fall");
		else
			animation.play("run");
	}

	public function idle() : Void
	{
		if (velocity.y == 0)
			animation.play("idle");
		else
			animation.play("jump");
	}

	public function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "idle":
				velocity.y = -100;
			case "alert":
				timer = new FlxTimer(0.4, onAlertTimer);
			case "chase":
				velocity.y = -100;
		}

		state = newState;
	}

	public function distanceToPlayer() : Float
	{
		return player.getPosition().distanceTo(getMidpoint());
	}
}