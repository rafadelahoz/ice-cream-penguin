package;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxRandom;
import flixel.util.FlxRect;

class HorizontalFlameSpawner extends EnemySpawner
{
	var capacity : Int = 10;
	var screenCount : Int = 2;
	
	var group : FlxTypedGroup<HorizontalFlameHazard>;
	var zoneRect : FlxRect;
	
	public function new(X : Int, Y : Int, World : PlayState, Width : Int, Height : Int, SecondsPerSpawn : Float)
	{
		super(X, Y, World, Width, Height, SecondsPerSpawn);
		
		zoneRect = new FlxRect(X, Y, Width, Height);
	}
	
	override public function init()
	{
		group = new FlxTypedGroup<HorizontalFlameHazard>(capacity);
		for (i in 0...capacity)
		{
			var flame : HorizontalFlameHazard = new HorizontalFlameHazard(Std.int(x), Std.int(y), world);
			flame.kill();
			group.add(flame);
		}
		world.mobileHazards.add(group);
		
		prepareSpawn();
	}
	
	override public function destroy() : Void
	{
		world.mobileHazards.remove(group);
		group.destroy();
		group = null;
	
		super.destroy();
	}
	
	override public function spawn() : Void
	{
		// Only spawn if the player is in the spawn zone
		if (zoneRect.containsFlxPoint(world.penguin.getMidpoint()) &&
		// And there are no more entities that we want alive at the same time
			(group.countLiving() < screenCount))
		{		
			var cam : FlxCamera = FlxG.camera;
		
			// Get a recycled entitiy
			var spawnee : HorizontalFlameHazard = group.recycle(HorizontalFlameHazard);

			var spawnX : Int = 0;
			var spawnY : Int = 0;
			
			// Spawn at the right camera border
			spawnX = Std.int(cam.scroll.x + cam.width + 8);
			
			// Choose y position
			spawnY = FlxRandom.intRanged(Std.int(cam.scroll.y), Std.int(cam.scroll.y + cam.height - spawnee.height));
			
			spawnee.init(spawnX, spawnY, FlxObject.LEFT);
		}
		
		prepareSpawn();
	}
}