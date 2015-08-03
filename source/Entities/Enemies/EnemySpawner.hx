package;

import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
import flixel.util.FlxRandom;

class EnemySpawner extends FlxObject
{
	var secondsPerSpawnVariation : Float = 0.3;
	
	var world : PlayState;
	
	var secondsPerSpawn : Float;
	var timer : FlxTimer;
	
	public function new(X : Int, Y : Int, World : PlayState, Width : Int, Height : Int, SecondsPerSpawn : Float)
	{
		super(X, Y, Width, Height);
		
		world = World;
		secondsPerSpawn = SecondsPerSpawn;
		
		timer = new FlxTimer();
		solid = false;
		
		init();
		
		// Won't call prepareSpawn automatically, do that by hand
	}
	
	// Override this
	function init() : Void
	{
		// Init your group or something
	}
	
	// Override this
	function spawn() : Void
	{
		// Spawn something(s)
	}
	
	function doSpawn(_timer : FlxTimer) : Void
	{
		// Spawn thing here
		spawn();
	}
	
	function prepareSpawn() : Void
	{
		timer.start(getSpawnTime(secondsPerSpawn, secondsPerSpawnVariation), doSpawn);
	}
	
	function getSpawnTime(baseTime : Float, variation : Float) : Float
	{
		var timeDelta : Float = baseTime * variation;
		return baseTime + FlxRandom.floatRanged(-timeDelta, timeDelta);
	}
}