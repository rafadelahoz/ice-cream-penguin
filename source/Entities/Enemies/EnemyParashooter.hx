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
	var bullets : FlxTypedGroup<BulletHazard>;
	
	var canvas : FlxSprite;

	public function new(X : Int, Y : Int, World: PlayState)
	{
		super(X, Y, World);
		
		type = "Parashooter";
		hazardType = Hazard.HazardType.None;

		makeGraphic(16, 16, 0xFF550120);
		
		timer = new FlxTimer();
		
		bullets = new FlxTypedGroup<BulletHazard>(shoots * 5);
		for (i in 0...shoots * 5)
		{
			var bullet : BulletHazard = new BulletHazard(x, y, world, Hazard.HazardType.Fire);
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
		world.mobileHazards.remove(bullets);
		bullets.destroy();
		bullets = null;
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
		var bullet : BulletHazard = bullets.recycle(BulletHazard);
		var shootSpeed : FlxPoint = calculateShootVelocity(player.getMidpoint());
		bullet.init(Std.int(getMidpoint().x), Std.int(getMidpoint().y - 16), shootSpeed.x, shootSpeed.y);
	}
	
	function calculateShootVelocity(target : FlxPoint) : FlxPoint
	{
		var from : FlxPoint = getMidpoint();
		
		var g : Float = GameConstants.Gravity; // gravity
		
		var v : Float = getMidpoint().distanceTo(target) / 0.25;// velocity
		
		var x : Float = Math.abs(target.x - from.x); // target x
		var y : Float = target.y - from.y;
		
		var s : Float = (v * v * v * v) - g * (g * (x * x) + 2 * y * (v * v)); //substitution
		if (s < 0) s = -s;
		var sqrtS : Float = Math.sqrt(s);		
		var angle = Math.atan(((v * v) + sqrtS) / (g * x)); // launch angle
		
		var speed = new FlxPoint();
		speed.x = Math.cos(angle) * v;
		speed.y = -Math.sin(angle) * v;
		
		if (from.x > target.x)
			speed.x *= -1;
		
		return speed;
	}
}