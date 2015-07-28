package;

import flixel.FlxSprite;

class Enemy extends Entity
{
	public var type : String;
	public var hazardType : Hazard.HazardType;

	var player (get, null) : Penguin;
	var _player : Penguin;
	function get_player() : Penguin
	{		
		if (_player == null) 
		{
			_player = world.penguin;
		}
		
		if (_player == null)
			trace("null player!");
		return _player;
	}
	
	var icecream (get, null) : Icecream;
	var _icecream : Icecream;
	function get_icecream() : Icecream
	{		
		if (_icecream == null) 
		{
			_icecream = world.icecream;
		}
		
		if (_icecream == null)
			trace("null icecream!");
		return _icecream;
	}

	var brain : StateMachine;

	public function new(X : Float = 0, Y : Float = 0, World : PlayState = null)
	{
		super(X, Y, World);

		player = world.penguin;
		hazardType = Hazard.HazardType.None;
		collideWithLevel = true;
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