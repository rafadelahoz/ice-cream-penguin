package;

import flixel.FlxSprite;

class Entity extends FlxSprite
{
	var world : PlayState;
	
	public var frozen : Bool;
	public var collideWithLevel : Bool;

	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y);
		world = World;
		frozen = false;
		collideWithLevel = true;

		world.entities.add(this);
	}

	public function freeze() : Void
	{
		frozen = true;
	}

	public function resume() : Void
	{
		frozen = false;
	}

	public function isFrozen() : Bool
	{
		return frozen;
	}

	override public function destroy() : Void
	{
		world.entities.remove(this);
	}
}