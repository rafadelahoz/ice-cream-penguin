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
			instance = new PlayFlowManager(Gui);
		
		if (World != null)
			instance.world = World;
		
		return instance;
	}

	public var world : PlayState;
	public var paused : Bool;
	public var group : FlxGroup;

	var circle : FlxSprite;
	var circleColor : Int;
	var radius : Float = 256;
	var radiusSpeed : Float = 5;
	var minRadius : Float = 185;
	var waitingDuration : Float = 1;

	var currentPhase : Phase;

	public function new(?gui : GUI)
	{
		super();

		create();
		if (gui != null)
			group.add(gui);
	}

	override public function destroy() : Void
	{
		group.destroy();
		group = null;
		circle = null;

		instance = null;
	}

	public function create() : Void
	{
		paused = false;
		group = new FlxGroup();

		circle = new FlxSprite(0, 0);
		circle.makeGraphic(FlxG.width, FlxG.height, 0x00000000, true);
		circle.scrollFactor.set();
		group.add(circle);

		/*var txt : FlxText = new FlxText(FlxG.width/2, 16, "DEAD!");
		txt.scrollFactor.set();
		group.add(txt);*/

		currentPhase = Phase.Alive;
	}

	public function onUpdate() : Bool
	{
		if (paused)
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
						FlxG.switchState(new PrelevelState());
					}
				default:

			}

			circle.x = 0;
			circle.y = 0;

			var ox = world.icecream.getMidpoint().x - FlxG.camera.scroll.x;
			var oy = world.icecream.getMidpoint().y - FlxG.camera.scroll.y;

			// circle.fill(0x00000000);
			circle.drawRect(0, 0, FlxG.width, FlxG.height, 0x00000000);
			circle.drawCircle(ox, oy, radius, 0x00000000, { color : circleColor, thickness: 300});
			
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

	public function onTimer(timer : FlxTimer) : Void
	{
		if (currentPhase == Phase.Waiting)
			currentPhase = Phase.Ending;
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
		currentPhase = Phase.Closing;
		
		circleColor = color;
	}
}

enum Phase { Alive; Closing; Waiting; Ending; }