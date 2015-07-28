package;

import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
import flixel.util.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using flixel.util.FlxVelocity;

class EnemySlowFloater extends Enemy
{
	var chaseDistance : Int = 400;
	var chargeTime : Float = 0.6;
	var chargeSpeed : Float = 18; // In pixels-per-second
	var floatAmplitude : Float = 8;
	var angleDelta : Float = 0.05;
		
	var floatAngle : Float;
	var floatY : Float;
	var baseOffsetY : Int;
	
	public function new(X : Int, Y : Int, World : PlayState)
	{
		super(X, Y, World);
		
		hazardType = Hazard.HazardType.Fire;
		
		collideWithLevel = false;
		
		makeGraphic(16, 24, 0xFF27566B);
		setSize(16, 16);
		baseOffsetY = 4;
		
		brain = new StateMachine(null, onStateChange);
		brain.transition(idle, "idle");
		
		floatAngle = 0;
	}
	
	override public function update() : Void
	{
		if (frozen)
			return;
			
		floatAngle += angleDelta;
		if (floatAngle >= 360)
			floatAngle = 0;
			
		super.update();
	}
	
	public function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "idle":
				alpha = 0.6;
			case "charge":
				alpha = 0.8;
		}
	}
	
	public function idle()
	{
		floatyFloaty();
		
		// Chase the icecream if it is near enough
		if (getMidpoint().distanceTo(icecream.getMidpoint()) < chaseDistance)
		{
			brain.transition(charge, "charge");
		}
	}
	
	public function charge()
	{
		moveTowardsPoint(icecream.getMidpoint(), chargeSpeed);		
		
		floatyFloaty();
		
		if (getMidpoint().distanceTo(icecream.getMidpoint()) >= chaseDistance)
		{
			brain.transition(idle, "idle");
		}
	}
	
	private function floatyFloaty() : Void
	{
		// Floaty floaty		
		floatY = Math.sin(floatAngle) * floatAmplitude;
		offset.y = baseOffsetY + floatY;
	}
}