package;

import flixel.FlxG;
import flixel.util.FlxSave;

class GameController 
{
	public static var SAVESLOTS (get, null) : Array<String>;
	static inline function get_SAVESLOTS() : Array<String> { return ["SAVE0", "SAVE1", "SAVE2"]; }
	public static var SAVESLOT = "SAVE0";

	private static var gameSave : FlxSave;

	public static var GameStatus : GameStatusData;
	
	/** Game Management API **/
	public static function ToTitleScreen()
	{
		FlxG.switchState(new MenuState());
	}
	
	public static function ToGameSelectScreen()
	{
		FlxG.switchState(new GamefileState());
	}
	
	public static function ToWorldMap()
	{
		FlxG.switchState(new WorldMapState());
	}
	
	
	/** Status handling functions **/
	
	public static function NewGame()
	{
		GameController.clearSave();
		GameController.init();
		GameController.save();
	}
	
	public static function SaveGame()
	{
		GameStatus.newGame = false;
		
		save();
	}
	
	public static function ContinueGame()
	{
		load();
	}
	
	public static function getLock(lock : String) : Bool
	{
		var open : Bool = false;
	
		trace("lock: " + lock);
	
		if (lock == null)
			open = true;
		else if (GameStatus.locks.exists(lock))
			open = GameStatus.locks.get(lock);
		else
			open = false;
			
		trace("Lock \"" + lock + "\" is " + (open ? "open" : "closed"));
		
		return open;
	}
	
	public static function setLock(lock : String, open : Bool) : Void
	{
		trace((open ? "Opening" : "Closing") + " lock \"" + lock + "\"");
	
		if (lock != null)
			GameStatus.locks.set(lock, open);
		else
			trace("Error: trying to set lock " + lock + " to value " + open);
	}
	
	/** Low Level Save/Load API **/
	
	public static function init() 
	{
		gameSave = new FlxSave();
		
		GameStatus = {
			newGame: true,
			currentLevel: "0",
			currentWorld: "0",
			locks: new Map<String, Bool>()
		};
	}
	
	public static function checkSavefiles() : Map<String, GameStatusData>
	{
		var savefilesMap : Map<String, GameStatusData> = new Map<String, GameStatusData>();
		
		for (saveslot in SAVESLOTS)
		{
			savefilesMap.set(saveslot, checkSaveslot(saveslot));
		}
		
		return savefilesMap;
	}
	
	public static function checkSaveslot(slot : String) : GameStatusData
	{
		gameSave.bind(slot);
		var data : GameStatusData = gameSave.data.gameStatus;
		// Do this explode?
		gameSave.destroy();
		return data;
	}
	
	public static function clearSave()
	{
		gameSave.bind(SAVESLOT);
		gameSave.data.gameStatus = null;
		gameSave.data.locks = null;
		gameSave.close();
	}
	
	public static function save() 
	{
		
		gameSave.bind(SAVESLOT);
		gameSave.data.gameStatus = GameStatus;
		gameSave.data.locks = generateLockStructure(GameStatus.locks);
		trace("Saving " + gameSave.data);
		gameSave.close();
	}
	
	public static function load() 
	{
		gameSave.bind(SAVESLOT);
		if (gameSave.data.gameStatus == null)
		{
			trace("Load unsuccessful");
		}
		else 
		{
			GameStatus = gameSave.data.gameStatus;
			GameStatus.locks = processLockStructure(gameSave.data.locks);
			trace("Loaded: " + gameSave.data);
		}
	}
	
	/** Data parsing **/
	
	private static function generateLockStructure(locks : Map<String, Bool>) : Dynamic
	{
		var lockNames : Array<String> = new Array<String>();
		var lockValues : Array<Bool> = new Array<Bool>();
		
		for (key in locks.keys())
		{
			lockNames.push(key);
			lockValues.push(locks.get(key));
		}
		
		var lockStruct = {
			names : lockNames,
			values : lockValues
		};
		
		return lockStruct;
	}
	
	private static function processLockStructure(lockStruct : Dynamic) : Map<String, Bool>
	{
		var locks : Map<String, Bool> = new Map<String, Bool>();
		
		trace("Processing locks: " + lockStruct);
		
		for (i in 0...Std.int(lockStruct.names.length))
		{
			locks.set(lockStruct.names[i], lockStruct.values[i]);
			trace("Lock " + lockStruct.names[i] + ": " + lockStruct.values[i]);
		}
		
		return locks;
	}
}


typedef GameStatusData = { 
	newGame : Bool,
	currentWorld: String,
	currentLevel: String,
	locks : Map<String, Bool>
}