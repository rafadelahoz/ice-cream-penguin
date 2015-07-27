package;

import flixel.util.FlxPoint;
import flixel.group.FlxTypedGroup;

class ShooterComponent
{
	var world	: PlayState;
	var bullets : FlxTypedGroup<BulletHazard>;
	
	public function new()
	{
		// ohai
	}
	
	public function init(World : PlayState, ?BulletHazardType : Hazard.HazardType = null, MaxBullets : Int = 5)
	{
		world = World;
	
		if (BulletHazardType == null)
			BulletHazardType = Hazard.HazardType.None;
	
		bullets = new FlxTypedGroup<BulletHazard>(MaxBullets);

		for (i in 0...MaxBullets)
		{
			var bullet : BulletHazard = new BulletHazard(-1, -1, World, BulletHazardType);
			bullet.kill();
			bullets.add(bullet);
		}
		
		World.mobileHazards.add(bullets);
	}
	
	public function shoot(from : FlxPoint, target : FlxPoint)
	{
		var bullet : BulletHazard = bullets.recycle(BulletHazard);
		var shotSpeed : FlxPoint = CalculateShootVelocity(from, target);
		bullet.init(Std.int(from.x), Std.int(from.y), shotSpeed.x, shotSpeed.y);
	}
	
	public function destroy()
	{
		world.mobileHazards.remove(bullets);
		bullets.destroy();
		bullets = null;
	}
	
	public static function CalculateShootVelocity(from : FlxPoint, target : FlxPoint) : FlxPoint
	{	
		var g : Float = GameConstants.Gravity; // gravity
		
		var v : Float = from.distanceTo(target) / 0.25;// velocity
		
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