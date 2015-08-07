package;

import flixel.util.FlxSave;

class GameController 
{
	private static var SAVESLOT = "SAVE";

	private static var gameSave : FlxSave;

	public static var GameStatus : GameStatusData;
	
	public static function init() 
	{
		gameSave = new FlxSave();
		
		GameStatus = {		
			currentLevel: "0",
			currentWorld: "0",
			locks: new Map<String, Bool>()
		};
	}
	
	/** Status handling functions **/
	
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
	
		if (lock != null && open != null)
			GameStatus.locks.set(lock, open);
		else
			trace("Error: trying to set lock " + lock + " to value " + open);
	}
	
	/** Save/Load API **/
	
	public static function clearSave()
	{
		gameSave.bind(SAVESLOT);
		gameSave.data = null;
		gameSave.flush();
	}
	
	public static function save() 
	{
		// trace("Saving: " + GameStatus);
		gameSave.bind(SAVESLOT);
		gameSave.data.gameStatus = GameStatus;
		gameSave.data.locks = generateLockStructure(GameStatus.locks);
		trace("Saving " + gameSave.data);
		gameSave.flush();
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
	currentWorld: String,
	currentLevel: String,
	locks : Map<String, Bool>
}