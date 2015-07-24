package;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GushingHazard extends Hazard
{
	static var StatusIdle : String = "Idle";
	static var StatusActivating : String = "Activating";
	static var StatusActive : String = "Active";
	static var StatusDeactivating : String = "Deactivating";
	static var StatusInactive : String = "Inactive";

	var configured : Bool;
	
	var activeWidth : Int;
	var activeHeight : Int;
	
	var idleTime : Float;		// Time spent in the Idle state
	var activeTime : Float;		// Time spent in the Active state
	var startupTime : Float;	// Time to begin in the Idle state (to offset gushers)
	
	var timer : FlxTimer;
	var currentStatus : String;
	var deltaAlpha : Float;

	public function new(X : Int, Y : Int, World : PlayState, Type : Hazard.HazardType)
	{
		super(X, Y, Type, World);
		
		configured = false;
		
		activeWidth = 16;
		activeHeight = 40;
		
		// TODO: Load appropriate graphic, setup animations
		switch (type)
		{
			case Hazard.HazardType.Fire:
				color = FlxColor.RED;
			case Hazard.HazardType.Water:
				color = FlxColor.BLUE;
			case Hazard.HazardType.Dirt:
				color = FlxColor.PUCE;
			default:
				color = 0xFFFF00FF;
		}
		
		trace(color);
		
		makeGraphic(activeWidth, activeHeight, color);
	}
	
	/**
	* Configures the Gusher with the appropriate times, and starts it
	**/
	public function configure(IdleTime : Float = 2.5, ActiveTime : Float = 2.5, StartupTime : Float = 0) : Void
	{
		idleTime = IdleTime;
		activeTime = ActiveTime;
		startupTime = StartupTime;
		
		currentStatus = StatusInactive;
		timer = new FlxTimer(startupTime, toIdle);
		
		configured = true;
	}
	
	override public function update() : Void
	{
		switch (currentStatus)
		{
			case GushingHazard.StatusIdle:
				alpha = 0.1;
			case GushingHazard.StatusActivating:
				alpha += deltaAlpha;
			case GushingHazard.StatusActive:
				alpha = 1;
			case GushingHazard.StatusDeactivating:
				alpha += deltaAlpha;
			default:
		}
		
		super.update();
	}
	
	public function toIdle(?theTimer : FlxTimer) : Void
	{
		currentStatus = StatusIdle;
		setOffset(0, activeHeight-1);
		makeGraphic(activeWidth, 1, color);
		timer = new FlxTimer(idleTime, toActivating);
	}
	
	public function toActivating(?theTimer : FlxTimer) : Void
	{
		currentStatus = StatusActivating;
		deltaAlpha = 1/(activeTime/2);
		timer = new FlxTimer(activeTime/2, toActive);
	}
	
	public function toActive(?theTimer : FlxTimer) : Void
	{
		currentStatus = StatusActive;
		setOffset(0, 0);
		makeGraphic(activeWidth, activeHeight, color);
		timer = new FlxTimer(activeTime, toDeactivating);
	}
	
	public function toDeactivating(?theTimer : FlxTimer) : Void
	{
		currentStatus = StatusDeactivating;
		deltaAlpha = -1/(activeTime/2);
		timer = new FlxTimer(activeTime/2, toIdle);
	}
}