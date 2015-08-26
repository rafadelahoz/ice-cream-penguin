package;

import flixel.FlxObject;

class HorizontalFlameHazard extends Hazard
{
	public var speed = 60;

	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, Hazard.HazardType.Fire, World);
		
		collideWithLevel = false;
	
		makeGraphic(32, 16, 0xFFFF294F);
	}
	
	public function init(X : Int, Y : Int, Direction : Int)
	{
		x = X;
		y = Y;
		
		centerOrigin();
		
		facing = Direction;
		if (facing == FlxObject.LEFT)
			velocity.x = -speed;
		else if (facing == FlxObject.RIGHT)
			velocity.x = speed;
		else
			kill();
	}
	
	override public function update() : Void
	{
		if (PlayFlowManager.get().paused)
		{
			return;
		}
		
		if (!inWorldBounds())
		{
			kill();
		}
		
		super.update();
	}
}