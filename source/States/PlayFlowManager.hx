package;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
using flixel.util.FlxSpriteUtil;

class PlayFlowManager extends FlxObject
{
	static var instance : PlayFlowManager;
	public static function get(?World : PlayState = null, ?Gui : GUI = null) : PlayFlowManager
	{
		if (instance == null)
		{
			instance = new PlayFlowManager(Gui);
		}
		
		if (World != null)
			instance.world = World;
		
		return instance;
	}

	public var world : PlayState;
	public var paused : Bool;
	public var group : FlxGroup;
	
	var spotlightFx : SpotlightEffect;
	
	var gui : GUI;

	public function new(?Gui : GUI)
	{
		super();

		create();
		
		if (Gui != null)
		{
			gui = Gui;
			group.add(gui);
		}
	}

	override public function destroy() : Void
	{
		group.destroy();
		group = null;
		
		spotlightFx.destroy();
		spotlightFx = null;

		instance = null;
	}

	public function create() : Void
	{
		paused = false;
		group = new FlxGroup();

		spotlightFx = new SpotlightEffect();
		group.add(spotlightFx);

		/*var txt : FlxText = new FlxText(FlxG.width/2, 16, "DEAD!");
		txt.scrollFactor.set();
		group.add(txt);*/
	}

	public function onUpdate() : Bool
	{
		if (paused)
		{
			/* Update the GUI */
			gui.updateGUI(world.icecream, world);
		
			// Update the Spotlight
			var ox = world.icecream.getMidpoint().x - FlxG.camera.scroll.x;
			var oy = world.icecream.getMidpoint().y - FlxG.camera.scroll.y;
			
			spotlightFx.target.x = ox;
			spotlightFx.target.y = oy;
			
			group.update();
			super.update();
			
			return false;
		}

		return true;
	}

	public function onDraw() : Bool
	{
		if (paused)
		{
		 	group.draw();
		 	super.draw();

		 	return false;
		}

		return true;
	}

	public function onGoal() : Void
	{
		if (!paused)
		{
			trace("You win!");
			doFinish(0xffED0086);
		}
	}

	public function onDeath(deathType : String) : Void
	{
		if (!paused) 
		{
			trace("Dead by " + deathType);
			doFinish(0xff000000);
		}
	}
	
	function doFinish(color : Int) : Void
	{
		for (entity in world.entities)
		{
			entity.freeze();
		}

		paused = true;
		
		spotlightFx.close(color, function() {			
			FlxG.switchState(new WorldMapState());
		});
	}
}