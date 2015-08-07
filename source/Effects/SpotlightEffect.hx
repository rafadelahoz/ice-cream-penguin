package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
using flixel.util.FlxSpriteUtil;

class SpotlightEffect extends FlxSprite
{
	var effectColor : Int;
	var initialClosingRadius : Float = 256;
	var initialOpeningRadius : Float = 0;
	var radiusSpeed : Float = 4;
	var pauseRadius : Float = 32;
	var waitingDuration : Float = 1;

	public var target : FlxPoint;
	var currentPhase : Phase;
	var callbackFunction : Void -> Void;
	var radius : Float;
	var targetRadius : Float;
	var radiusDelta : Float;
	var opening : Bool;
	
	public function new()
	{
		super(0, 0);
		
		makeGraphic(FlxG.width, FlxG.height, 0x00000000, true);
		scrollFactor.set();
		
		blend = flash.display.BlendMode.MULTIPLY;
		
		currentPhase = Phase.Idle;
	}
	
	override public function update() : Void
	{		
		switch (currentPhase)
		{
			case Opening, Closing: 
				radius += radiusDelta;
				if (opening && (radius > pauseRadius) ||
					!opening && (radius < pauseRadius))
				{
					trace("Stop: " + waitingDuration + "s");
					radius = pauseRadius;
					currentPhase = Phase.Waiting;
					new FlxTimer(waitingDuration, onTimer);
				}
			case Waiting:
			case Ending:
				radius += radiusDelta * 0.8;
				if (!opening && radius <= targetRadius || 
					opening && radius >= targetRadius)
				{					
					radius = targetRadius;
					if (callbackFunction != null) 
					{
						callbackFunction();
					}
					
					currentPhase = Phase.Finished;
				}
			case Finished:
			default:
		}
		
		switch (currentPhase)
		{
			case Phase.Idle:
			case Phase.Opening, Phase.Closing, Phase.Waiting, Phase.Ending:
				fill(effectColor);
				if (radius > 1)
					drawCircle(target.x, target.y, radius, 0xFFFFFFFF);
			case Phase.Finished:
				if (opening)
					fill(0x00000000);
				else
					fill(0xFFFFFFFF);
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
		trace("Timer!");
		if (currentPhase == Phase.Waiting)
			currentPhase = Phase.Ending;
	}
	
	public function open(?Target : FlxPoint = null, ?Wait : Float = 1,/* ?Color : Int = 0xFF000000,*/ ?Callback : Void -> Void = null)
	{
		prepareEffect(Target, Wait, Callback);
		
		currentPhase = Opening;
		opening = true;
		
		radius = initialOpeningRadius;
		targetRadius = initialClosingRadius;
		radiusDelta = radiusSpeed;
	}
	
	public function close(?Target : FlxPoint = null, ?Wait : Float = 1,/* ?Color : Int = 0xFF000000,*/ ?Callback : Void -> Void = null) 
	{
		prepareEffect(Target, Wait, Callback);
		
		currentPhase = Closing;
		opening = false;
		
		radius = initialClosingRadius;
		targetRadius = initialOpeningRadius;
		radiusDelta = -radiusSpeed;
	}
	
	public function cancel() : Void
	{
		currentPhase = Phase.Ending;
	}
	
	private function prepareEffect(?Target : FlxPoint = null, ?Wait : Float = 1,/* ?Color : Int = 0xFF000000,*/ ?Callback : Void -> Void = null) : Void
	{
		makeGraphic(FlxG.width, FlxG.height, 0x00000000, true);
		scrollFactor.set();
	
		// Point to the center if no target is given
		target = Target;
		if (target == null)
			target = new FlxPoint(FlxG.camera.scroll.x + FlxG.camera.width / 2, 
								  FlxG.camera.scroll.y + FlxG.camera.height / 2);
		
		effectColor = 0xFF000000;
		callbackFunction = Callback;
		waitingDuration = Wait;
	}
}

enum Phase { Idle; Opening; Closing; Waiting; Ending; Finished; }