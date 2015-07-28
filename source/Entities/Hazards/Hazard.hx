package;

import flixel.FlxSprite;

class Hazard extends Entity
{
	public var type : HazardType;
	public var dangerous : Bool;

	var player : Penguin;

	public function new(X : Float = 0, Y : Float = 0, ?Type : HazardType, World : PlayState = null)
	{
		super(X, Y, World);
		
		if (Type == null)
			Type = HazardType.None;
		
		type = Type;
		dangerous = true;
		
		collideWithLevel = false;
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

enum HazardType { None; Fire; Water; Dirt; Collision; }