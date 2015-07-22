package;

import flixel.FlxSprite;

class Enemy extends Entity
{
	public var type : String;

	var player : Penguin;

	var brain : StateMachine;

	public function new(X : Float = 0, Y : Float = 0, World : PlayState = null)
	{
		super(X, Y, World);

		player = world.penguin;

	}

	override public function update() : Void
	{
		if (frozen)
			return;
		
		brain.update();
		super.update();
	}

	public function onCollisionWithPlayer(player : Penguin)
	{
		// delegating...
	}
	
	public function onCollisionWithIcecream(icecream : Icecream)
	{
		// delegating...
	}
}