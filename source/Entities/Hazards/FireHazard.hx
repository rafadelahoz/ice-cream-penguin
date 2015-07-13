package;

import flixel.FlxObject;

class FireHazard extends Hazard
{
	public function new(X : Float = 0, Y : Float = 0, World : PlayState = null)
	{
		super(X, Y, Hazard.HazardType.Fire, World);

		makeGraphic(16, 16, 0xDDAA0101);
	} 

	override public function onCollisionWithPlayer(player : Penguin)
	{
		// Player bounces, stunned?
		trace("yay");
		player.bounce();
	}

	override public function onCollisionWithIcecream(icecream : FlxObject) 
	{
		// Melt icecream
	}
}