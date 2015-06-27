package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;

import flixel.tile.FlxTilemap;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{

	var penguin : Penguin;
	var ground : FlxGroup;
	var level : TiledLevel;

	var doCollide : Bool;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.debugger.visible = true;
		FlxG.log.redirectTraces = true;

		doCollide = false;



		// Load the tiled level
		level = new TiledLevel("assets/maps/0.tmx");
		// Add tilemaps
		add(level.foregroundTiles);

		add(level.backgroundTiles);

		add(penguin = new Penguin(Std.int(FlxG.width / 2), Std.int(FlxG.height / 2) - 32));

		/*ground = new FlxGroup();
		var _gnd : FlxSprite = new FlxSprite(0, FlxG.height - 54).makeGraphic(FlxG.width, 56, 0x99FFFFFF);
		_gnd.immovable = true;
		FlxG.watch.add(_gnd, "y");
		ground.add(_gnd);
		add(ground);*/

		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		penguin.destroy();
		// ground.destroy();

		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		doCollide = !(FlxG.keys.anyPressed(["ENTER"]));

		if (doCollide)
		{
			// FlxG.collide(penguin, ground);
			level.collideWithLevel(penguin);
		}

		super.update();
	}	
}