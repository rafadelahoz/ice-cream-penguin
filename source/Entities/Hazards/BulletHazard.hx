package;

import flixel.FlxObject;

enum Behaviour { None; Parabolic; Straight; }

class BulletHazard extends Hazard
{
	public var behaviour : Behaviour;
	
	public function new(X : Float = 0, Y : Float = 0, World : PlayState)
	{
		super(X, Y, World);
	}

	public function init(X : Int, Y : Int, HSpeed : Float, VSpeed : Float, ?BulletBehaviour : Behaviour)
	{
		makeGraphic(10, 10, 0xFFDD2140);
	
		if (BulletBehaviour == null)
			BulletBehaviour = Behaviour.Parabolic;
		behaviour = BulletBehaviour;
		
		x = X;
		y = Y;
		velocity.set(HSpeed, VSpeed);
		acceleration.y = GameConstants.Gravity;
	}
	
	override public function update()
	{
		if (!isOnScreen() || justTouched(FlxObject.ANY))
			kill();
		
		super.update();
	}
}