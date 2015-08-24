package;

import flash.display.BitmapData;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxVirtualPad;
import flixel.ui.FlxButton;

@:bitmap("assets/images/ui/virtualpad/x.png")
private class GraphicX extends BitmapData {}

class GamePad
{
	public static var virtualPad : PenguinVirtualPad;
	
	static var previousPadState : Map<Int, Bool>;
	static var currentPadState : Map<Int, Bool>;
	
	public static function setupVirtualPad() : Void
	{	
		virtualPad = new PenguinVirtualPad();
		virtualPad.alpha = 0.65;

		setupVPButton(virtualPad.buttonRight);
		setupVPButton(virtualPad.buttonLeft);
		virtualPad.buttonLeft.x += 10;
		setupVPButton(virtualPad.buttonA);
		setupVPButton(virtualPad.buttonB);
		virtualPad.buttonB.x += 10;
		setupVPButton(virtualPad.buttonPause, true);
		
		initPadState();
	}
	
	public static function handlePadState() : Void
	{
		previousPadState = currentPadState;
		currentPadState = new Map<Int, Bool>();
		currentPadState.set(Left, 
			virtualPad.buttonLeft.status == FlxButton.PRESSED || FlxG.keys.anyPressed(["LEFT"]));
		currentPadState.set(Right, 
			virtualPad.buttonRight.status == FlxButton.PRESSED || FlxG.keys.anyPressed(["RIGHT"]));
		currentPadState.set(A, 
			virtualPad.buttonA.status == FlxButton.PRESSED || FlxG.keys.anyPressed(["A", "Z", "SPACE"]));
		currentPadState.set(B, 
			virtualPad.buttonB.status == FlxButton.PRESSED || FlxG.keys.anyPressed(["S", "X", "CONTROL"]));
		currentPadState.set(Pause, 
			virtualPad.buttonPause.status == FlxButton.PRESSED || FlxG.keys.anyPressed(["ESCAPE"]));
	}
	
	public static function checkButton(button : Int) : Bool
	{
		return currentPadState.get(button);
	}

	public static function justPressed(button : Int) : Bool
	{
		return currentPadState.get(button) && !previousPadState.get(button);
	}

	public static function justReleased(button : Int) : Bool
	{
		return !currentPadState.get(button) && previousPadState.get(button);
	}

	private static function setupVPButton(button : FlxSprite, small : Bool = false) : Void
	{
		if (!small)
		{
			button.scale.x = 0.5;
			button.scale.y = 0.5;
			button.width *= 0.5;
			button.height *= 0.5;
			button.updateHitbox();
			button.y += 17;
		}
		else
		{
			button.scale.x = 0.3;
			button.scale.y = 0.3;
			button.width *= 0.3;
			button.height *= 0.3;
			button.updateHitbox();
		}
	}
	
	private static function initPadState() : Void
	{
		currentPadState = new Map<Int, Bool>();
		currentPadState.set(Left, false);
		currentPadState.set(Right, false);
		currentPadState.set(A, false);
		currentPadState.set(B, false);
		currentPadState.set(Pause, false);

		previousPadState = new Map<Int, Bool>();
		previousPadState.set(Left, false);
		previousPadState.set(Right, false);
		previousPadState.set(A, false);
		previousPadState.set(B, false);
		previousPadState.set(Pause, false);
	}

	public static var Left : Int = 0;
	public static var Right : Int = 1;
	public static var A : Int = 2;
	public static var B : Int = 3;
	public static var Pause : Int = 4;
}

class PenguinVirtualPad extends FlxVirtualPad
{
	public var buttonPause : FlxButton;

	public function new()
	{
		super(LEFT_RIGHT, A_B);
		dPad.add(add(buttonPause = createButton(FlxG.width - 15, 3, 44, 45, GraphicX)));
	}
}