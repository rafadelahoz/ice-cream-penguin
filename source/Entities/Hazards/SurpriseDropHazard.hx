package;

import flixel.FlxObject;
import flixel.util.FlxPoint;
import flixel.tweens.FlxTween;

using flixel.util.FlxSpriteUtil;

class SurpriseDropHazard extends Hazard
{
	var fallDistance : Int = 8;

	var brain : StateMachine;

	public function new(X : Float, Y : Float, World : PlayState, Type : Hazard.HazardType)
	{
		super(X, Y, Type, World);

		makeGraphic(16, 16, 0x00000000);
		drawRoundRect(1, 1, 14, 14, 8, 8, 0xFF673F30);
		
		collideWithLevel = true;
		
		setPlayer(world.penguin);
		
		brain = new StateMachine(null, onStateChange);
		brain.transition(waiting, "waiting");
	}
	
	override public function update()
	{
		if (frozen)
		{
			acceleration.set(0, 0);
			velocity.set(0, 0);
			return;
		}
		
		if (scale.y <= 0) super.kill();
		
		brain.update();		
		
		super.update();
	}
	
	public function waiting() : Void
	{
		velocity.set(0, 0);
		acceleration.set(0, 0);
		
		solid = false;
		
		var pos : FlxPoint = player.getMidpoint();
		
		if (checkPlayerX(pos) && checkPlayerY(pos))
			brain.transition(fall, "fall");
	}
	
	public function fall() : Void
	{
		solid = true;
		
		acceleration.y = GameConstants.Gravity;
		
		if (isTouching(FlxObject.DOWN))
			kill();
	}
	
	override public function kill() : Void
	{
		if (alive)
		{
			velocity.set(0, 0);
			acceleration.set(0, 0);
			
			// Play some effect
			alive = false;
			var tween : FlxTween = FlxTween.tween(scale, { x:1, y:0 }, 0.075);
			
			brain.transition(null);
		}
	}
	
	function checkPlayerX(playerPos : FlxPoint) : Bool
	{
		return Math.abs((playerPos.x - getMidpoint().x)) < fallDistance;
	}
	
	function checkPlayerY(playerPos : FlxPoint) : Bool
	{
		return playerPos.y > (y + height);
	}
	
	
	public function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "waiting":
			case "fall":
				velocity.y = -70;
			default:
		}
	}
}