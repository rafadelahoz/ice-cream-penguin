package;

import flixel.FlxSprite;

class Entity extends FlxSprite
{
	public var frozen : Bool;

	var world : PlayState;

	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y);
		world = World;
		frozen = false;

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