package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.scaleModes.PixelPerfectScaleMode;

class GamefileState extends GameState
{
	var headerText : FlxText;
	var menuText : FlxText;
	
	var options : Array<Option>;
	
	var currentOption : Int;
	
	public var deleting : Bool;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		headerText = new FlxText(0, 0);
		headerText.text = "Choose a save file";
		add(headerText);
		
		options = new Array<Option>();
		
		var saveslots : Array<String> = GameController.SAVESLOTS;
		var savesdata : Map<String, GameController.GameStatusData> = GameController.checkSavefiles();
		
		var slotX : Int = 16;
		var slotY : Int = 32;
		var deltaY : Int = 32;
		
		for (saveslot in saveslots)
		{
			var gameFile : GameFile = new GameFile(slotX, slotY, getSlotName(saveslot), saveslot, savesdata.get(saveslot));
			options.push(gameFile);
			add(gameFile);
			
			slotY += deltaY;
		}
		
		var deleteBtn : Option = new Option(slotX, slotY, "Delete file");
		options.push(deleteBtn);
		add(deleteBtn);
		
		currentOption = 0;
		
		focusSlot(currentOption);
		
		deleting = false;
	}
	
	static function getSlotName(saveslot : String) : String
	{
		switch (saveslot)
		{
			case "SAVE0": return "File 1";
			case "SAVE1": return "File 2";
			case "SAVE2": return "File 3";
		}
		
		return "Invalid file";
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		
		var previousOption : Int = currentOption;
	
		if (deleting)
		{
			options[3].color = 0xFF3131FF;
		}
		else if (currentOption != 3)
		{
			options[3].color = 0xFFFFFFFF;
		}

		if (!options[currentOption].awaitingConfirmation || currentOption == 3)
		{
			if (GamePad.justPressed(GamePad.Left))
			{
				currentOption -= 1;
				if (currentOption < 0)
					currentOption = options.length - 1;
			}
			else if (GamePad.justPressed(GamePad.Right))
			{
				currentOption += 1;
				if (currentOption >= options.length)
					currentOption = 0;
			}
			
			if (currentOption != previousOption)
				focusSlot(currentOption, previousOption);
		}
		
		if (GamePad.justPressed(GamePad.A))
			handleSelectedOption();
		if (GamePad.justPressed(GamePad.B))
			handleCancelledOption();
			
		if (GamePad.justReleased(GamePad.Pause))
			GameController.ToTitleScreen();
	}
	
	function focusSlot(newSlot : Int, oldSlot : Int = -1) : Void
	{
		if (oldSlot > -1 && (!deleting || oldSlot != 3))
			options[oldSlot].blur();
			
		if (newSlot > -1 && (!deleting || newSlot != 3))
			options[newSlot].focus();
	}
	
	function handleCancelledOption()
	{
		if (deleting && (!options[currentOption].awaitingConfirmation || currentOption == 3))
			deleting = false;
		options[currentOption].cancelled();
	}
	
	function handleSelectedOption()
	{
		if (deleting)
		{
			if (currentOption == 3)
			{
				// deleting = false;
				options[currentOption].focus();
			}
			else if (options[currentOption].deleted())
			{
				var deletedFile : GameFile = (cast options[currentOption]);
				var saveslot = deletedFile.slotName;
				
				// Delete the save!
				GameController.SAVESLOT = saveslot;
				GameController.clearSave();
				
				options[currentOption] = new GameFile(deletedFile.x, deletedFile.y, getSlotName(saveslot), saveslot, null);
				add(options[currentOption]);
				
				remove(deletedFile);
				deletedFile.destroy();
				deletedFile = null;
				
				deleting = false;
			}
		}
		else
			options[currentOption].selected();
		
		if (currentOption == 3)
			deleting = !deleting;
	}
}

class Option extends FlxSprite
{
	var name : String;
	
	var text : FlxText;

	public var focused : Bool;
	public var awaitingConfirmation : Bool;

	public function new(X : Float, Y : Float, Name : String)
	{
		super(X, Y);
		
		name = Name;
		
		text = new FlxText();
		text.text = Name;
		text.x = X;
		text.y = Y;
		
		makeGraphic(1, 1, 0x00000000);
		
		focused = false;
	}
	
	override public function update() 
	{
		text.color = color;
		text.update();
		super.update();
	}
	
	override public function draw()
	{
		super.draw();
		text.draw();
	}
	
	public function focus() : Void
	{
		color = 0xFFFA0231;
	}
	
	public function blur() : Void
	{
		color = 0xFFFFFFFF;
	}
	
	public function selected() : Void
	{
		if (!awaitingConfirmation)
		{
			color = 0xFF02FA31;
			awaitingConfirmation = true;
		}
	}
	
	public function cancelled() : Void
	{
		if (awaitingConfirmation)
		{
			awaitingConfirmation = false;
			color = 0xFFFA0231;
		}
	}
	
	public function deleted() : Bool
	{
		return false;
	}
}

class GameFile extends Option
{
	public var slotName : String;
	var data : GameController.GameStatusData;
	var dataText : String;
	var tween : FlxTween;
	
	public function new(X : Float, Y : Float, Name : String, Slotname : String, Data : GameController.GameStatusData)
	{
		super(X, Y, Name);

		slotName = Slotname;
		data = Data;
		
		text = prepareDataDisplay(Name, Data);
		text.x = X;
		text.y = Y;
		dataText = text.text;
		
		makeGraphic(1, 1, 0x00000000);
		
		focused = false;
	}
	
	static function prepareDataDisplay(name : String, data : GameController.GameStatusData) : FlxText
	{
		var text : FlxText = new FlxText();
		
		if (data == null || data.newGame)
			text.text = name + ": New game";
		else
			text.text = name + ": Blue Penguin    " + "Level " + data.currentWorld + "-" + data.currentLevel + "\n" +
						"10 deliveries        2 friends";
			
		return text;
	}
	
	override public function update() 
	{
		text.color = color;
		text.update();
		super.update();
	}
	
	override public function draw()
	{
		super.draw();
		text.draw();
	}
	
	override public function focus() : Void
	{
		color = 0xFFFA0231;
	}
	
	override public function blur() : Void
	{
		color = 0xFFFFFFFF;
	}
	
	override public function selected() : Void
	{
		if (!awaitingConfirmation)
		{
			color = 0xFF02FA31;
			awaitingConfirmation = true;
			text.text = dataText + "?";
		}
		else
		{
			GameController.SAVESLOT = slotName;
			
			if (data == null)
			{
				trace("=== New game ===");
				GameController.NewGame();
			} 
			else 
			{
				trace("=== Restore game ===");
				GameController.ContinueGame();
				
			}
			
			GameController.ToWorldMap();
		}
	}
	
	override public function cancelled() : Void
	{
		if (awaitingConfirmation)
		{
			awaitingConfirmation = false;
			text.text = dataText;
			color = 0xFFFA0231;
		}
	}
	
	override public function deleted() : Bool
	{
		if (!awaitingConfirmation)
		{
			text.text = "Delete " + dataText + "?";
			color = 0xFF31FAFA;
			awaitingConfirmation = true;
			
			return false;
		}
		else
		{
			return true;
		}
	}
}