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
	var shootTime : Float = 1;
	var shoots : Int = 1;
		
	var timer : FlxTimer;
	var shooter : ShooterComponent;

	public function new(X : Int, Y : Int, World: PlayState)
	{
		super(X, Y, World);
		
		type = "Parashooter";
		hazardType = Hazard.HazardType.None;
		solid = false;

		// makeGraphic(16, 16, 0xFF550120);
		loadGraphic("assets/images/plant-sheet.png", true, 32, 24);
		animation.add("idle", [4]);
		animation.add("open", [4, 5], 6, false);
		animation.add("shoot", [6]);
		animation.play("idle");
		
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
		animation.play("idle");
	}
	
	public function shoot()
	{
		if (animation.name == "open" && animation.finished)
		{
			animation.play("shoot");

			// Shoot!
			shootBullet();
			
			// Wait a tad...
			timer.start(shootTime, function(t : FlxTimer) : Void {
				// And idle
				brain.transition(idle, "idle");
			});
			
		}
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
				animation.play("open");
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