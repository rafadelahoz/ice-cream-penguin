package;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import openfl.display.BlendMode;

class Collectible extends Entity
{
	var _floaty : Bool;
	var floaty (get, set) : Bool;
	function get_floaty() : Bool
	{		
		return _floaty;
	}
	
	function set_floaty(value : Bool) : Bool
	{
		_floaty = value;
		if (_floaty && tween == null)
		{
			tween = FlxTween.tween(this, { y : y+floatDistance }, Math.random() + 1, { type : FlxTween.PINGPONG, ease : FlxEase.quadIn });
		}
		else if (!_floaty && tween != null)
		{
			tween.cancel();
			tween = null;
		}
		
		return _floaty;
	}
	
	var tween : FlxTween;
	public var floatDistance : Int = 4;
	
	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);
		
		tween = null;
		floaty = false;
	}
	
	override public function update()
	{
		if (frozen)
		{
			if (tween != null)
			{
				tween.cancel();
				tween = null;
			}
			return;
		}
		else
		{
			floaty = floaty;
		}
		
		if (scale.x <= 0) super.kill();
		
		super.update();
	}
	
	// This is to be ovveridden
	public function onCollisionWithPlayer(penguin : Penguin) : Void
	{
		// Do nothing!
		
		// And disappear
		kill();
	}
	
	override public function kill():Void 
	{
		if (tween != null)
			tween.cancel();
		alive = false;
		blend = BlendMode.ADD;
		tween = FlxTween.tween(scale, { x:0, y:2 }, 0.075);
		velocity.y = -150;
	}
}