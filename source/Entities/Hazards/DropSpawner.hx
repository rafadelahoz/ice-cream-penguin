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
		
		waitTime = WaitTime;
		
		timer = new FlxTimer(waitTime, spawnDrop);
		
		makeGraphic(2, 2, 0xfffd01fd);
	}
	
	public function spawnDrop(_timer : FlxTimer) : Void
	{
		world.mobileHazards.add(new DropHazard(getMidpoint().x, getMidpoint().y, world, type));
		timer = new FlxTimer(waitTime, spawnDrop);
	}
}