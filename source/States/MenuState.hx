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
class MenuState extends GameState
{
	var titleText : FlxText;
	var menuText : FlxText;
	
	var currentOption : Int;
	var options : Int;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		titleText = new FlxText(0, 0);
		titleText.text = "Penguin Game";
		add(titleText);
		
		menuText = new FlxText(FlxG.width / 2 - 48, 2 * FlxG.height / 3, 96);
		menuText.text = "- Continue\n New game \n";
		add(menuText);

		var fixedSM : flixel.system.scaleModes.PixelPerfectScaleMode = new PixelPerfectScaleMode();
		FlxG.scaleMode = fixedSM;
		
		GameController.init();
		
		options = 2;
		currentOption = 0;
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

		if (GamePad.justPressed(GamePad.Left))
		{
			currentOption -= 1;
			if (currentOption < 0)
				currentOption = options - 1;
		}
		else if (GamePad.justPressed(GamePad.Right))
		{
			currentOption += 1;
			if (currentOption >= options)
				currentOption = 0;
		}
		
		if (currentOption == 0)
			menuText.text = "- Continue\n New game \n";
		else if (currentOption == 1)
			menuText.text = " Continue \n- New game\n";
		
		if (GamePad.justPressed(GamePad.A))
			handleSelectedOption();
	}
	
	function handleSelectedOption()
	{
		switch (currentOption)
		{
			case 0:
				trace("=== Restore game ===");
				// Continue
				GameController.load();
				FlxG.switchState(new WorldMapState());
			case 1:
				trace("=== New game ===");
				// New game
				GameController.clearSave();
				GameController.init();
				GameController.save();
				FlxG.switchState(new WorldMapState());
		}
	}
}