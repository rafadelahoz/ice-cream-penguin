package;

using flixel.util.FlxSpriteUtil;

class IceShard extends Collectible
{
	public var value : Float = 10;
	
	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);
		
		floaty = true;
		
		makeGraphic(10, 10, 0x00000000);
		drawRoundRect(1, 1, 8, 8, 3, 3, 0xFFEEF8FF);
	}
	
	override public function onCollisionWithPlayer(pen : Penguin) : Void
	{
		world.icecream.makeColder(value);
		super.onCollisionWithPlayer(pen);
	}
}