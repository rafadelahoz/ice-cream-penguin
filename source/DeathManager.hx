package;

import flixel.group.FlxGroup;

class DeathManager 
{
	public var paused : Bool;
	public var group : FlxGroup;

	public function new()
	{
		create();
	}

	public function create() : Void
	{
		paused = false;
		group = new FlxGroup();
	}

	public function update() : Bool
	{
		if (paused)
		{
			group.update();
			return false;
		}

		return true;
	}

	public function draw() : Bool
	{
		if (paused)
		{
		 	group.draw();
		 	return false;
		}

		return true;
	}

	public function onDeath(deathType : String) : Void
	{
		paused = true;
	}
}