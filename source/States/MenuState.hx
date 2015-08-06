package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.system.scaleModes.PixelPerfectScaleMode;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	var titleText : FlxText;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();

		titleText = new FlxText(0, 0);
		titleText.text = "Penguin Game";
		add(titleText);

		var fixedSM : flixel.system.scaleModes.PixelPerfectScaleMode = new PixelPerfectScaleMode();
		FlxG.scaleMode = fixedSM;
		
		GameController.init();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();

		titleText = null;
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();

		if (FlxG.keys.anyJustReleased(["A"]))
		{
			trace("Loading...");
			GameController.load();
			
			FlxG.switchState(new PrelevelState());
		}
		else if (FlxG.keys.anyJustReleased(["ENTER"]))
		{
			FlxG.switchState(new WorldMapState());
		}
	}	
}