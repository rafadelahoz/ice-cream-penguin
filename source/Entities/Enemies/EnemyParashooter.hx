package;

import flixel.util.FlxTimer;
import flixel.group.FlxTypedGroup;

class EnemyParashooter extends Enemy
{
	var idleTime : Float = 4.0;
	var shoots : Int = 1;
		
	var timer : FlxTimer;
	var bullets : FlxTypedGroup<BulletHazard>;

	public function new(X : Int, Y : Int, World: PlayState)
	{
		super(X, Y, World);
		
		type = "Parashooter";
		hazardType = Hazard.HazardType.None;

		makeGraphic(16, 16, 0xFF550120);
		
		timer = new FlxTimer();
		
		bullets = new FlxTypedGroup<BulletHazard>(shoots);
		for (i in 0...shoots * 5)
		{
			var bullet : BulletHazard = new BulletHazard(x, y, world);
			bullet.kill();
			bullets.add(bullet);
		}
		world.mobileHazards.add(bullets);
		
		brain = new StateMachine(null, onStateChange);
		brain.transition(idle, "idle");
		
		immovable = true;
	}
	
	override public function destroy()
	{
		timer.destroy();
		// Shall the bullets group be removed?
	}
	
	public function idle()
	{
	}
	
	public function shoot()
	{
		// Shoot
		var bullet : BulletHazard = bullets.recycle(BulletHazard);
		bullet.init(Std.int(getMidpoint().x), Std.int(getMidpoint().y - 16), 200, -200);
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
}