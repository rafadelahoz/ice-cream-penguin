package;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxRandom;
import flixel.util.FlxRect;

class EnemyFlyDropSpawner extends EnemySpawner
{
	var capacity : Int = 10;
	var group : FlxTypedGroup<EnemyFlyDrop>;
	var zoneRect : FlxRect;
	
	public function new(X : Int, Y : Int, World : PlayState, Width : Int, Height : Int, SecondsPerSpawn : Float)
	{
		super(X, Y, World, Width, Height, SecondsPerSpawn);
		
		zoneRect = new FlxRect(X, Y, Width, Height);
	}
	
	override public function init()
	{
		group = new FlxTypedGroup<EnemyFlyDrop>(capacity);
		for (i in 0...capacity)
		{
			var flyDrop : EnemyFlyDrop = new EnemyFlyDrop(Std.int(x), Std.int(y), world);
			flyDrop.kill();
			group.add(flyDrop);
		}
		world.enemies.add(group);
		
		prepareSpawn();
	}
	
	override public function spawn() : Void
	{
		// Only spawn if the player is in the spawn zone
		if (zoneRect.containsFlxPoint(world.penguin.getMidpoint()))
		{		
			var cam : FlxCamera = FlxG.camera;
		
			// Get a recycled entitiy
			var spawnee : EnemyFlyDrop = group.recycle(EnemyFlyDrop);

			var spawnX : Int = 0;
			var spawnY : Int = 0;
			
			// Choose whether to spawn at left or right camera border
			if (FlxRandom.chanceRoll(50))
			{
				// Right
				spawnX = Std.int(cam.scroll.x + cam.width + 8);
			}
			else
			{
				spawnX = Std.int(cam.scroll.x - spawnee.width - 8);
			}
			
			// Choose y position
			spawnY = FlxRandom.intRanged(Std.int(cam.scroll.y), Std.int(cam.scroll.y + (cam.height)/2));
		
			trace("Spawning at " + spawnX + ", " + spawnY);
		
			spawnee.x = spawnX;
			spawnee.y = spawnY;
			spawnee.init();
		}
		
		prepareSpawn();
	}
}