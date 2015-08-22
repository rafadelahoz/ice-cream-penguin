package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxRandom;

class EnemyFlyDrop extends Enemy	
{
	var sineGeneratorDelta : Float = 0.06;
	var amplitude : Float = 8;
	var hspeed : Int = 45;
	var stunnedHspeedFactor : Float = 0.25;
	
	var baseY : Float;
	var sineGenerator : Float;
	
	var dropper : DropSpawner;

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
		loadGraphic("assets/images/flydrop-bird.png", true, 32, 32);
		animation.add("fall", [0]);
		animation.add("rise", [1]);
		animation.play("fall");

		setSize(20, 18);
		offset.set(6, 8);
		
		if (player.getMidpoint().x < getMidpoint().x)
		{
			facing = FlxObject.LEFT;
		}
		else
		{
			facing = FlxObject.RIGHT;
		}
			
		baseY = y;
		
		sineGenerator = FlxRandom.intRanged(0, 359);
		
		dropper = new DropSpawner(Std.int(getMidpoint().x), Std.int(getMidpoint().y), world, Hazard.HazardType.Dirt);
		
		brain = new StateMachine(null);
		brain.transition(fly, "fly");
	}
	
	override public function kill()
	{
		if (dropper != null)
			dropper.destroy();
		super.kill();
	}

	override public function update()
	{
		if (frozen)
			return;
			
		if (x < FlxG.camera.scroll.x - FlxG.camera.width/2 || x > FlxG.camera.scroll.x + FlxG.camera.width * 1.5)
			kill();
			
		super.update();
	}
	
	public function fly()
	{
		acceleration.y = 0;
	
		sineGenerator += sineGeneratorDelta;
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
		
		var sine : Float = Math.sin(sineGenerator);
		y = baseY + sine * amplitude;

		if (sine < 0)
			animation.play("rise");
		else
			animation.play("fall");
		
		dropper.x = getMidpoint().x;
		dropper.y = getMidpoint().y;
		dropper.update();
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