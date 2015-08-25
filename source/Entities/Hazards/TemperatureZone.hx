package;

import flixel.FlxObject;

class TemperatureZone extends FlxObject
{
	public var isSpecific(default, null) : Bool;
	public var mpsSpecific(default, null) : Float;
	public var mpsMultiplier(default, null) : Float;
	
	public function new(X : Float, Y : Float, Width : Int, Height : Int)
	{
		super(X, Y, Width, Height);	
	}
	
	public function setSpecificMPS(mps : Float) : Void
	{
		mpsSpecific = mps;
		isSpecific = true;
	}
	
	public function setMultiplierMPS(multiplier : Float) : Void
	{
		mpsMultiplier = multiplier;
		isSpecific = false;
	}
}