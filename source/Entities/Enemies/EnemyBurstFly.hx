package;

import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
import flixel.util.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using flixel.util.FlxVelocity;

class EnemyBurstFly extends Enemy
{
	var idleBaseTime : Float = 2.5;
	var idleVarTimeFactor : Float = 0.15;
	var chaseDistance : Int = 100;
	var chargeTime : Float = 0.6;
	var chargeSpeed : Float = 50; // In pixels-per-second
	var randomTargetRadius : Int = 24;
	var retarget : Bool = false;

	var canTurn : Bool;
	var timer : FlxTimer;
	var tween : FlxTween;
	var mobileTarget : Bool;
	var target : FlxPoint;
	
	public function new(X : Int, Y : Int, World : PlayState)
	{
		super(X, Y, World);
	}

	override public function init(?Category : Int, ?Variation : Int)
	{
		super.init(Category, Variation);

		collideWithLevel = false;
		collideWithEnemies = false;
		
		if (Category == GameConstants.W_MONSTER)
		{
			if (Variation == null || Variation < 0 )
				Variation = 0;
			else if (Variation > 1)
				Variation = 1;

			loadGraphic("assets/images/fly-monster.png", true, 24, 20);
			animation.add("idle", [Variation, Variation+1], 4);
			animation.add("charge", [Variation, Variation+1], 8);

			setSize(12, 12);
			offset.set(6, 5);

			hazardType = Hazard.HazardType.Theft;

			canTurn = true;
		}
		else if (Category == GameConstants.W_WATER)
		{
			loadGraphic("assets/images/fly-water.png", true, 16, 16);
			animation.add("idle", [0, 1], FlxRandom.intRanged(2, 5));
			animation.add("charge", [0, 1], FlxRandom.intRanged(6, 10));

			setSize(10, 10);
			offset.set(3, 3);

			hazardType = Hazard.HazardType.Water;

			canTurn = false;
		}
		else
		{
			loadGraphic("assets/images/fly.png", true, 24, 24);
			animation.add("idle", [0, 1, 2, 1], 30);
			animation.add("charge", [0, 1, 2, 1], 50);

			setSize(8, 8);
			offset.set(8, 7);

			hazardType = Hazard.HazardType.Dirt;

			canTurn = true;
		}

		animation.play("idle");
		
		timer = new FlxTimer();
		
		brain = new StateMachine(null, onStateChange);
		brain.transition(idle, "idle");
	}
	
	override public function update() : Void
	{
		if (frozen)
		{
			timer.active = false;
			animation.paused = true;
			tween.cancel();
			return;
		}
		else
		{
			timer.active = true;
			animation.paused = false;
		}
			
		if (canTurn)
		{
			if (icecream.getMidpoint().x < getMidpoint().x)
				flipX = true;
			else
				flipX = false;
		}

		super.update();
	}
	
	public function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "idle":
				// Animation
				animation.play("idle");

				// Start the idle floaty motion
				tween = FlxTween.tween(this, {x: x, y: y + 4}, 0.5, { type: FlxTween.PINGPONG, ease: FlxEase.quadInOut });
				
				// Charge after some time
				timer.start(decideIdleTime(), function (_timer : FlxTimer) {
					brain.transition(charge, "charge");
				});
			case "charge":
				// Animation
				animation.play("charge");

				// Stop the idle motion
				tween.cancel();
				
				// Choose your target
				// Chase the icecream if it is near enough
				if (getMidpoint().distanceTo(icecream.getMidpoint()) < chaseDistance)
				{
					target = icecream.getMidpoint();
					mobileTarget = true;
				}
				else // Move to a random near point
				{
					target = chooseRandomTarget();
					mobileTarget = false;
				}
				
				
				timer.start(chargeTime, function (_timer : FlxTimer) {
					brain.transition(idle, "idle");
				});
			case "drown":
				tween.cancel();
		}
	}
	
	public function idle()
	{
		// Floaty floaty
	}
	
	public function charge()
	{
		moveTowardsPoint(target, chargeSpeed);
		if (retarget && mobileTarget)
			target = icecream.getMidpoint();
	}
	
	public function chooseRandomTarget() : FlxPoint
	{
		var angle : Float = FlxRandom.intRanged(0, 359);
		angle = MathUtils.degToRad(angle);
		var length : Float = FlxRandom.intRanged(0, randomTargetRadius);
		
		var target : FlxPoint = new FlxPoint();
		target.x = Math.cos(angle) * length;
		target.y = Math.sin(angle) * length;
		
		return target;
	}
	
	public function decideIdleTime() : Float
	{
		var maxVarTime : Float = idleBaseTime*idleVarTimeFactor;
		var varTime : Float = FlxRandom.floatRanged(-maxVarTime, maxVarTime);
		return idleBaseTime + varTime;
	}

	override public function onCollisionWithIcecream(icecream : Icecream) 
	{
		if (hazardType == Hazard.HazardType.Fire)
		{
			// Melt icecream
			icecream.makeHotter(10);
		}
		else if (hazardType == Hazard.HazardType.Theft)
		{
			icecream.steal(this);
		}
		else if (hazardType == Hazard.HazardType.Dirt)
		{
			icecream.mud(101);
		}
		else if (hazardType == Hazard.HazardType.Water)
		{
			icecream.water(101);
		}
	}
}