package;

import flixel.util.FlxTimer;

class FallingFlameHazard extends DropHazard
{
	var timer : FlxTimer;

	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World, Hazard.HazardType.Fire);
	}
	
	override function handleGraphicByType(Type : Hazard.HazardType) : Void
	{
		loadGraphic("assets/images/falling-hazards.png", true, 13, 13);
		
		// Setup mask
		setSize(7, 7);
		offset.set(3, 3);
		
		// Setup anims
		animation.add("fall", [4]);	
		animation.add("splash", [5, 6, 7], 8, false);
		animation.play("fall");
		animated = true;
	}
	
	override public function update() : Void
	{
		if (PlayFlowManager.get().paused)
		{
			if (timer != null)
				timer.active = false;
				
			velocity.set();
			acceleration.set();
				
			return;
		}
		
		if (timer != null)
			timer.active = true;
		
		super.update();
	}
	
	override public function splash() : Void
	{
		acceleration.set(0, 0);
		velocity.set(0, 0);
	}
	
	override public function onStateChange(nextState : String) : Void
	{
		if (nextState == "splash")
		{
			makeGraphic(9, 12, 0xFFFF294F);
			offset.set(2, 1);
			timer = new FlxTimer(2, function(t : FlxTimer) {
				t.cancel();
				kill();
			});
		}
	}
	
	override public function onCollisionWithIcecream(icecream : Icecream)
	{
		switch (type)
		{
			case Hazard.HazardType.Fire:
				icecream.makeHotter(100);
			case Hazard.HazardType.Water:
				icecream.water(100);
			case Hazard.HazardType.Dirt:
				icecream.mud(100);
			default:
		}
		
		brain.transition(splash, "splash");
	}
}