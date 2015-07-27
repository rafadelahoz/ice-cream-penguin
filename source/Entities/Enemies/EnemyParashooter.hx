package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.util.FlxPoint;
import flixel.group.FlxTypedGroup;
using flixel.util.FlxSpriteUtil;

class EnemyParashooter extends Enemy
{
	var idleTime : Float = 4;
	var shoots : Int = 1;
		
	var timer : FlxTimer;
	var shooter : ShooterComponent;

	public function new(X : Int, Y : Int, World: PlayState)
	{
		super(X, Y, World);
		
		type = "Parashooter";
		hazardType = Hazard.HazardType.None;

		makeGraphic(16, 16, 0xFF550120);
		
		timer = new FlxTimer();
		
		shooter = new ShooterComponent();
		shooter.init(world, Hazard.HazardType.Fire, 5);
		
		brain = new StateMachine(null, onStateChange);
		brain.transition(idle, "idle");
		
		immovable = true;
	}
	
	override public function destroy()
	{
		timer.destroy();
		
		shooter.destroy();
	}
	
	override public function update()
	{
		if (frozen)
		{
			timer.active = false;
			return;
		}
		
		if (FlxG.mouse.justPressed)
			// Shoot!
			shootBullet();
		
		timer.active = true;
		
		super.update();
	}
	
	public function idle()
	{
	}
	
	public function shoot()
	{
		// Shoot!
		shootBullet();
		
		// And idle
		brain.transition(idle, "idle");
	}
	
	public function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "idle":
				timer.start(idleTime, 
					function (t : FlxTimer) : Void {
						brain.transition(shoot, "shoot");
					});
			case "shoot":
		}
	}
	
	public function shootBullet() : Void
	{
		// Shoot
		var origin : FlxPoint = getMidpoint();
		origin.y -= 16;
		
		shooter.shoot(origin, player.getMidpoint());
	}
}