package;

import flixel.FlxSprite;

class Hazard extends FlxSprite
{
	public var type : HazardType;

	var world : PlayState;
	var player : Penguin;

	public function new(X : Float = 0, Y : Float = 0, ?Type : HazardType, World : PlayState = null)
	{
		super(X, Y);

		type = Type;
		world = World;
	}

	public function setPlayer(thePlayer : Penguin) 
	{
		player = thePlayer;
	}

	public function onCollisionWithIcecream(icecream : Icecream)
	{

	}

	public function onCollisionWithPlayer(player : Penguin) 
	{

	}

	public function onCollisionWithEnemy(enemy : Enemy)
	{

	}
}

enum HazardType { Fire; Water; Dirt; Collision; }