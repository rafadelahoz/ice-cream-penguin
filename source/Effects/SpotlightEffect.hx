package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
using flixel.util.FlxSpriteUtil;

class SpotlightEffect extends FlxSprite
{
	var circleColor : Int;
	var initialRadius : Float = 256;
	var radiusSpeed : Float = 5;
	var minRadius : Float = 185;
	var waitingDuration : Float = 1;

	public var target : FlxPoint;
	var currentPhase : Phase;
	var callbackFunction : Void -> Void;
	var radius : Float;
	
	public function new()
	{
		super(0, 0);
		
		makeGraphic(FlxG.width, FlxG.height, 0x00000000, true);
		scrollFactor.set();
		
		currentPhase = Phase.Idle;
	}
	
	override public function update() : Void
	{
		switch (currentPhase)
		{
			case Closing:
				radius -= radiusSpeed;
				if (radius < minRadius)
				{
					radius = minRadius;
					currentPhase = Phase.Waiting;
					new FlxTimer(waitingDuration, onTimer);
				}
			case Waiting:
			case Ending:
				radius -= radiusSpeed * 0.8;
				if (radius <= 0) 
				{
					radius = 0;
					if (callbackFunction != null) 
					{
						callbackFunction();
					}
				}
			default:

		}

		if (currentPhase != Phase.Idle)
		{
			drawRect(0, 0, FlxG.width, FlxG.height, 0x00000000);
			drawCircle(target.x, target.y, radius, 0x00000000, { color : circleColor, thickness: 300});
		}
		
		super.update();
	}
	
	override public function draw()
	{
		if (currentPhase != Phase.Idle)
			super.draw();
	}
	
	public function onTimer(timer : FlxTimer) : Void
	{
		if (currentPhase == Phase.Waiting)
			currentPhase = Phase.Ending;
	}
	
	public function close(?Target : FlxPoint = null, ?Color : Int = 0xFF000000, ?Callback : Void -> Void = null) 
	{
		// Point to the center if no target is given
		target = Target;
		if (target == null)
			target = new FlxPoint(FlxG.camera.scroll.x + FlxG.camera.width / 2, 
								  FlxG.camera.scroll.y + FlxG.camera.height / 2);
	
		circleColor = Color;
		callbackFunction = Callback;
		currentPhase = Closing;
		
		radius = initialRadius;
	}
}


enum Phase { Idle; Closing; Waiting; Ending; }