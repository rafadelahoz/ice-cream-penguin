package;

using flixel.util.FlxSpriteUtil;

class IceShard extends Collectible
{
	public var value : Int = 10;
	
	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);
		
		floaty = true;
		
		loadGraphic("assets/images/iceshards.png", true, 16, 16);
		animation.add("idle", [0, 1, 2], 0, false);
		animation.play("idle", true, -1);

		setSize(10, 10);
		offset.set(3, 3);
	}
	
	override public function onCollisionWithPlayer(pen : Penguin) : Void
	{
		if (alive)
		{
			world.icecream.makeColder(value);
			super.onCollisionWithPlayer(pen);
		}
	}
}