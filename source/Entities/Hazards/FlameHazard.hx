package;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class FlameHazard extends Hazard
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

	var baseX : Float;
	var baseY : Float;

	public function new(X : Int, Y : Int, World : PlayState, Type : Hazard.HazardType)
	{
		Type = Hazard.HazardType.Fire;

		super(X, Y, Type, World);
		
		configured = false;
		
		activeWidth = 16;
		activeHeight = 40;
		
		// TODO: Load appropriate graphic, setup animations
		var gfxName : String = "assets/images/flame-gusher.png";
		loadGraphic(gfxName, true, 24, 40);

		animation.add("idle", 			[4]);
		animation.add("active", 		[2, 3], 12);
		animation.add("activating", 	[1, 2, 3], 8, false);
		animation.add("deactivating", 	[3, 2, 1], 8, false);

		animation.callback = animationStepCallback;

		setSize(10, 33);
		offset.set(7, 7);
		
		x -= 8;

		baseX = x;
		baseY = y;
		x = baseX - 0;
		y = baseY - 40;
	}
	
	public function animationStepCallback(Name : String, FrameNumber : Int, FrameIndex : Int) : Void
	{
		switch (FrameIndex)
		{
			case 0, 1, 4:
				dangerous = false;
			case 2, 3:
				dangerous = true;
		}
		/*switch (FrameIndex) 
		{
			case 0, 1, 2:
				dangerous = false;
				offset.set(14, 38);
				setSize(2, 2);
			case 3, 4, 5:
				dangerous = true;
				offset.set(8, 8);
				setSize(16, 32);
			case 6, 7, 8:
				dangerous = true;
				offset.set(13, 35);
				setSize(6, 5);
			case 9, 10, 11:
				dangerous = true;
				offset.set(13, 28);
				setSize(6, 12);
			case 12, 13, 14:
				dangerous = true;
				offset.set(13, 23);
				setSize(6, 17);
			case 15, 16, 17:
				dangerous = true;
				offset.set(11, 12);
				setSize(10, 28);
		}*/

		if (flipY)
			offset.y = 0;

		x = baseX - 0  + offset.x;
		y = baseY - 40 + offset.y;
	}

	/**
	* Configures the Gusher with the appropriate times, and starts it
	**/
	public function configure(IdleTime : Float = 2.5, ActiveTime : Float = 2.5, ?StartupTime : Float = 0, ?Inverse : Bool = false) : Void
	{
		idleTime = IdleTime;
		activeTime = ActiveTime;
		startupTime = StartupTime;
		
		currentStatus = StatusInactive;
		timer = new FlxTimer(startupTime, toIdle);
		
		dangerous = false;
		configured = true;

		flipY = Inverse;
		if (Inverse)
		{
			baseY += 32;
			resetSize();
		}
	}
	
	override public function update() : Void
	{
		if (frozen)
		{
			if (timer != null)
				timer.active = false;
			return;
		}

		if (timer != null)
			timer.active = true;

		switch (currentStatus)
		{
			case FlameHazard.StatusIdle:
				// dangerous = false;
			case FlameHazard.StatusActivating:
				// dangerous = true;
				if (animation.finished)
					toActive();
			case FlameHazard.StatusActive:
				// dangerous = true;
			case FlameHazard.StatusDeactivating:
				// dangerous = true;
				if (animation.finished)
					toIdle();
			default:
		}
		
		super.update();
	}
	
	public function toIdle(?theTimer : FlxTimer) : Void
	{
		currentStatus = StatusIdle;

		animation.play("idle");

		timer = timer.start(idleTime, toActivating);
	}
	
	public function toActivating(?theTimer : FlxTimer) : Void
	{
		currentStatus = StatusActivating;
		/*offset.set(8, 8);
		setSize(16, 32);*/
		animation.play("activating");
	}
	
	public function toActive(?theTimer : FlxTimer) : Void
	{
		currentStatus = StatusActive;
		animation.play("active");
		timer = timer.start(activeTime, toDeactivating);
	}
	
	public function toDeactivating(?theTimer : FlxTimer) : Void
	{
		currentStatus = StatusDeactivating;
		/*offset.set(11, 12);
		setSize(10, 28);*/
		animation.play("deactivating");
	}

	override public function onCollisionWithIcecream(icecream : Icecream) : Void
	{
		if (dangerous)
		{
			switch (type)
			{
				case Hazard.HazardType.Fire:
					icecream.makeHotter(20);
				case Hazard.HazardType.Water:
					icecream.water(20);
				case Hazard.HazardType.Dirt:
					icecream.mud(20);
				default:
			}
		}
	}
}