package;

import flixel.util.FlxSave;

class GameController 
{
	private static var gameSave : FlxSave;

	public static var GameStatus = {
		currentWorld : "0",
		currentLevel : "0"
	};
	
	public static function init() 
	{
		gameSave = new FlxSave();
		GameStatus.currentLevel = "0";
		GameStatus.currentWorld = "0";
	}
	
	public static function save() 
	{
		trace("Saving: " + GameStatus);
		gameSave.bind("SAVE0");
		gameSave.data.gameStatus = GameStatus;
		gameSave.flush();
	}
	
	public static function load() 
	{
		gameSave.bind("SAVE0");
		if (gameSave.data.gameStatus == null)
		{
			trace("Load unsuccessful");
		}
		else 
		{
			GameStatus = gameSave.data.gameStatus;
			trace("Loaded: " + GameStatus);
		}
	}
}