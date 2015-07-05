package;

import flixel.FlxSprite;

class Enemy extends FlxSprite
{
	public var type : String;

	var world : PlayState;
	var player : Penguin;

	var brain : StateMachine;

	public function new(X : Float = 0, Y : Float = 0, World : PlayState = null)
	{
		super(X, Y);

		world = World;
		player = world.penguin;

	}

	override public function update() : Void
	{
		brain.update();
		super.update();
	}

	public function onCollisionWithPlayer(player : Penguin)
	{
		// delegating...
	}
}