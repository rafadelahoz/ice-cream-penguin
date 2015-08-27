package;

import flixel.FlxObject;

enum Behaviour { None; Parabolic; Straight; }

class BulletHazard extends Hazard
{
	public var behaviour : Behaviour;
	
	public function new(X : Float = 0, Y : Float = 0, World : PlayState, ?Type : Hazard.HazardType)
	{
		super(X, Y, Type, World);
		
		loadGraphic("assets/images/droplet.png");
		color = 0xffffd700;
		
		collideWithLevel = false;
	}

	public function init(X : Int, Y : Int, HSpeed : Float, VSpeed : Float, ?BulletBehaviour : Behaviour)
	{
		if (BulletBehaviour == null)
			BulletBehaviour = Behaviour.Parabolic;
		behaviour = BulletBehaviour;
		
		x = X;
		y = Y;
		
		centerOrigin();
		
		velocity.set(HSpeed, VSpeed);
		
		switch (behaviour)
		{
			case Parabolic:
				acceleration.y = GameConstants.Gravity;
				maxVelocity.set(GameConstants.Gravity, GameConstants.Gravity);
			case Straight:
			case None:
		}
		
	}
	
	override public function update()
	{
		if (PlayFlowManager.get().paused)
		{
			return;
		}
	
		if (!inWorldBounds() || justTouched(FlxObject.ANY))
		{
			trace("bye!");
			kill();
		}
		
		super.update();
	}
	
	override public function onCollisionWithPlayer(player : Penguin) : Bool
	{
		kill();
		
		return false;
	}

	override public function onCollisionWithIcecream(icecream : Icecream)
	{
		// if (velocity.y != 0)
		{
			switch (type)
			{
				case Hazard.HazardType.Fire:
					icecream.makeHotter(100);
				case Hazard.HazardType.Water:
					icecream.water(100);
				case Hazard.HazardType.Dirt:
					icecream.mud(100);
				default:
			}
			
			// kill();
		}
	}
}