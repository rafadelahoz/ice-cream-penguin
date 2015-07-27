package;

import flixel.util.FlxTimer;

class DropSpawner extends Hazard
{
	var timer : FlxTimer;
	var waitTime : Float;
	
	public function new(X : Int, Y : Int, World : PlayState, ?WaitTime : Float = 2, ?Type : Hazard.HazardType)
	{
		if (Type == null)
			Type = Hazard.HazardType.None;
		
		super(X, Y, Type, World);
		
		makeGraphic(3, 3, 0xffdd0242);
		centerOffsets();
		centerOrigin();
		updateHitbox();
		
		waitTime = WaitTime;
		
		timer = new FlxTimer(waitTime, spawnDrop);
	}
	
	public function spawnDrop(_timer : FlxTimer) : Void
	{
		world.mobileHazards.add(new DropHazard(getMidpoint().x, getMidpoint().y, world, type));
		timer.reset(waitTime);
	}
}