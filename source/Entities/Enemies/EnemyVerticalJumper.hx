package;

import flixel.FlxG;
import flixel.util.FlxTimer;

class EnemyVerticalJumper extends Enemy
{
	public var idleTime : Float = 2;
	public var jumpSpeed : Float = 200;

	var timer : FlxTimer;
	var baseX : Float;
	var baseY : Float;

	public function new(X : Int, Y : Int, World : PlayState)
	{
		super(X, Y, World);
		
		baseX = X;
		baseY = Y;
	}

	override public function init(?Category : Int, ?Variation : Int)
	{
		super.init(Category, Variation);
		
		hazardType = Hazard.HazardType.Theft;

		collideWithLevel = false;
		
		makeGraphic(12, 24, 0xFF00C872);
		
		timer = new FlxTimer();
		
		brain = new StateMachine(null, onStateChange);
		brain.transition(idle, "idle");
		
		FlxG.debugger.track(this);
	}
	
	override public function update()
	{
		if (frozen)
		{
			timer.active = false;
			return;
		}
		
		timer.active = true;
		
		super.update();
	}
	
	function idle() : Void
	{
		velocity.set();
		acceleration.set();
	}
	
	function jump() : Void
	{
		velocity.x = 0;
	
		acceleration.y = GameConstants.Gravity * 0.5;
	
		if (y > baseY)
		{
			velocity.set();
			acceleration.set();
			
			brain.transition(idle, "idle");
		}
	}
	
	function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "idle":
				timer.start(idleTime, function(_t:FlxTimer) {
					x = baseX;
					y = baseY;
					
					brain.transition(jump, "jump");
				});
			case "jump":
				velocity.y = -jumpSpeed;
		}
	}
	
	override public function onCollisionWithPlayer(player : Penguin)
	{
		if (velocity.y < 0)
			velocity.y = 0;
	}
}