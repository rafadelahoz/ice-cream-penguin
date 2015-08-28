package;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
using flixel.util.FlxSpriteUtil;

class PlayFlowManager extends FlxObject
{
	static var instance : PlayFlowManager;
	public static function get(?World : PlayState = null, ?Gui : GUI = null) : PlayFlowManager
	{
		// There is no instance: create one
		if (instance == null)
		{
			instance = new PlayFlowManager(World, Gui);
		}
		// There is a former instance, update references
		else 
		{
			if (World != null)
				instance.world = World;
			if (Gui != null)
				instance.gui = Gui;
		}
		
		return instance;
	}

	public var world : PlayState;
	public var canResume : Bool;
	public var paused : Bool;
	public var group : FlxGroup;
	
	var spotlightFx : SpotlightEffect;
	
	var gui : GUI;
	
	var pauseGUI : FlxGroup;

	public function new(?World : PlayState, ?Gui : GUI)
	{
		super();

		if (World != null)
		{
			world = World;
		}
		
		create();
		
		if (Gui != null)
		{
			gui = Gui;
			group.add(gui);
		}
		
		pauseGUI = new FlxGroup();
		pauseGUI.add(new FlxSprite(FlxG.width / 2 - 40, FlxG.height / 4 - 2).makeGraphic(80, 32, 0x99000000));
		pauseGUI.add(new FlxText(FlxG.width / 2 - 32, FlxG.height / 4, 64, 		" ~ PAUSED! ~ ", 8));
		pauseGUI.add(new FlxText(FlxG.width / 2 - 32, FlxG.height / 4 + 16, 64, "A: Exit level", 8));
		pauseGUI.setAll("scrollFactor", new FlxPoint(0, 0));
		group.add(pauseGUI);
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

		new FlxTimer(0.01, function(_t:FlxTimer) {
			doPause(true);
			spotlightFx.open(world.penguin.getMidpoint(), function() {
				doUnpause(true);
			});
		});
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

	public function onGoal(goal : LevelGoal) : Void
	{
		if (!paused)
		{
			trace("You win!");
			
			// Do this in a more cool way
			GameController.setLock(goal.unlocks, true);
			
			doFinish(0xffED0086);
		}
	}

	public function onDeath(deathType : String) : Void
	{
		if (!paused) 
		{
			trace("Dead by " + deathType);

			world.penguin.onDeath(deathType);

			doFinish(0xff000000);
		}
	}
	
	function doFinish(color : Int) : Void
	{
		doPause(true);
		
		spotlightFx.close(function() {		
			// spotlightFx.cancel();

			// TODO: Move this into the SpotlightEffect class
			// Set screen to full black
			FlxG.camera.fade(0xFF000000, 0.0, false);
			// Wait a tad before going back
			new FlxTimer(0.75, function(_t:FlxTimer) {
				FlxG.switchState(new WorldMapState());
			});
		});
	}
	
	public function doPause(silent : Bool = false) : Void
	{
		pauseGUI.visible = !silent;
		canResume = !silent;
	
		paused = true;
		
		for (entity in world.entities)
		{
			entity.freeze();
		}
	}
	
	public function doUnpause(force : Bool = false) : Void
	{
		if (!canResume && !force)
			return;
	
		pauseGUI.visible = false;
		
		paused = false;
		
		for (entity in world.entities)
		{
			entity.resume();
		}
	}
}