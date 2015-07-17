package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;

/**
 * A FlxState which can be used for the game's menu.
 */
class PrelevelState extends FlxState
{
	var titleText : FlxText;
	var level : Int;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();

		level = 0;

		titleText = new FlxText(0, 0);
		titleText.text = "Level 1-" + level;
		
		titleText.x = FlxG.width/2 - titleText.width/2;
		titleText.y = FlxG.height/2 - titleText.height/2;

		add(titleText);
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

		if (FlxG.keys.anyJustReleased(["ENTER"]))
		{
			FlxG.switchState(new PlayState("" + level));
		}

		if (FlxG.keys.anyJustReleased(["UP"]))
			level++;
		else if (FlxG.keys.anyJustReleased(["DOWN"]))
			level--;

		titleText.text = "Level 1-" + level;
	}	
}