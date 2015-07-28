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
	var chaseDistance : Int = 160;
	var chargeTime : Float = 0.6;
	var chargeSpeed : Float = 50; // In pixels-per-second
	var randomTargetRadius : Int = 24;
	var retarget : Bool = false;

	var timer : FlxTimer;
	var tween : FlxTween;
	var mobileTarget : Bool;
	var target : FlxPoint;
	
	public function new(X : Int, Y : Int, World : PlayState)
	{
		super(X, Y, World);
		
		collideWithLevel = false;
		
		makeGraphic(10, 10, 0xFF4A2D73);
		
		timer = new FlxTimer();
		
		brain = new StateMachine(null, onStateChange);
		brain.transition(idle, "idle");
	}
	
	override public function update() : Void
	{
		if (frozen)
			return;
			
		super.update();
	}
	
	public function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "idle":
				// Start the idle floaty motion
				tween = FlxTween.tween(this, {x: x, y: y + 4}, 0.5, { type: FlxTween.PINGPONG, ease: FlxEase.quadInOut });
				
				// Charge after some time
				timer.start(decideIdleTime(), function (_timer : FlxTimer) {
					brain.transition(charge, "charge");
				});
			case "charge":
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
		alpha = 0.8;
	}
	
	public function charge()
	{
		alpha = 1;
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
}