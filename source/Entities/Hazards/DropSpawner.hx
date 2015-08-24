package;

import flixel.util.FlxTimer;
import flixel.group.FlxTypedGroup;

class DropSpawner extends Hazard
{
	var timer : FlxTimer;
	var waitTime : Float;
	
	var droplets : FlxTypedGroup<DropHazard>;
	
	public function new(X : Int, Y : Int, World : PlayState, ?WaitTime : Float = 2, ?Type : Hazard.HazardType)
	{
		if (Type == null)
			Type = Hazard.HazardType.None;
		
		super(X, Y, Type, World);
		
		droplets = new FlxTypedGroup<DropHazard>(5);
		for (i in 0...5)
		{
			var droplet : DropHazard = new DropHazard(x, y, world, Type);
			droplet.kill();
			droplets.add(droplet);
		}
		world.mobileHazards.add(droplets);
		
		makeGraphic(3, 3, 0xffdd0242);
		centerOffsets();
		centerOrigin();
		updateHitbox();
		
		waitTime = WaitTime;
		
		timer = new FlxTimer(waitTime, spawnDrop);
	}
	
	override public function destroy() : Void
	{
		world.mobileHazards.remove(droplets);
		droplets.destroy();
		droplets = null;

		timer.destroy();
	}
	
	public function spawnDrop(_timer : FlxTimer) : Void
	{
		var droplet : DropHazard = droplets.recycle(DropHazard);
		droplet.init(Std.int(getMidpoint().x), Std.int(getMidpoint().y), type);
		
		timer.reset(waitTime);
	}
	
	public function pause() : Void
	{
		timer.active = false;
	}
	
	public function unpause() : Void
	{
		timer.active = true;
	}
}