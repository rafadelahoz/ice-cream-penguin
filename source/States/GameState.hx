package;

import flixel.FlxState;

class GameState extends FlxState
{
	public function new()
	{
		super();
	}
	
	override public function create()
	{
		// Register the Virtual Pad
		GamePad.setupVirtualPad();
		add(GamePad.virtualPad);

		super.create();
	}
	
	override public function update()
	{
		GamePad.handlePadState();
	
		super.update();
	}
}