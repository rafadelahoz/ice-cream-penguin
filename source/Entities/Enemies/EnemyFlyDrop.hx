package;

import flixel.FlxObject;
import flixel.util.FlxRandom;

class EnemyFlyDrop extends Enemy	
{
	var sineGeneratorDelta : Float = 0.05;
	var amplitude : Float = 30;
	var hspeed : Int = 60;
	var stunnedHspeedFactor : Float = 0.25;
	
	var baseY : Float;
	var sineGenerator : Float;

	public function new(X : Int, Y : Int, World : PlayState)
	{
		super(X, Y, World);
	}
	
	override public function init(?Category : Int, ?Variation : Int)
	{
		super.init(Category, Variation);

		collideWithLevel = false;
		collideWithEnemies = false;
		
		makeGraphic(20, 18, 0xFF101010);
		
		if (player.getMidpoint().x < getMidpoint().x)
		{
			facing = FlxObject.LEFT;
			trace("GO LEFT");
		}
		else
		{
			facing = FlxObject.RIGHT;
			trace("GO RIGHT");
		}
			
		baseY = y;
		
		sineGenerator = FlxRandom.intRanged(0, 359);
		
		brain = new StateMachine(null);
		brain.transition(fly, "fly");
	}
	
	public function fly()
	{
		acceleration.y = 0;
		
		sineGenerator += amplitude;
		sineGenerator = sineGeneratorClamp(sineGenerator);
		
		if (facing == FlxObject.LEFT)
		{
			velocity.x = -hspeed;
			flipX = true;
		}
		else if (facing == FlxObject.RIGHT)
		{
			velocity.x = hspeed;
			flipX = false;
		}
			
		velocity.y = Math.sin(sineGenerator) * amplitude;
	}
	
	public function stunned()
	{
		acceleration.y = GameConstants.Gravity;
		
		if (facing == FlxObject.LEFT)
		{
			velocity.x = hspeed * stunnedHspeedFactor;
			flipX = true;
		}
		else if (facing == FlxObject.RIGHT)
		{
			velocity.x = -hspeed * stunnedHspeedFactor;
			flipX = false;
		}
		
		// animation.play("stunned");
	}
	
	static function sineGeneratorClamp(sineGenerator : Float) : Float
	{
		if (sineGenerator < 0)
			return 360 + sineGenerator;
		else if (sineGenerator >= 360)
			return sineGenerator - 360;
		else
			return sineGenerator;
	}
}