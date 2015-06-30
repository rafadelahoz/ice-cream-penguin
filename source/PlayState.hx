package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.FlxCamera;
import flixel.tile.FlxTilemap;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	var camera : FlxCamera;

	var penguin : Penguin;
	var icecream : FlxSprite;
	var ground : FlxGroup;
	var level : TiledLevel;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.debugger.visible = true;
		FlxG.log.redirectTraces = true;

		icecream = null;

		// Load the tiled level
		level = new TiledLevel("assets/maps/4.tmx");
		// Add tilemaps
		add(level.backgroundTiles);

		level.loadObjects(this);

		add(level.overlayTiles);

		FlxG.camera.follow(penguin, FlxCamera.STYLE_PLATFORMER, null, 0);

		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		penguin.destroy();

		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		if (FlxG.keys.anyPressed(["ENTER"])) {
			FlxG.camera.shake(0.02, 0.05);
		}

		level.collideWithLevel(penguin);
		
		super.update();
	}	

	public function addPenguin(p : Penguin) : Void
	{
		if (penguin != null)
			penguin = null;

		penguin = p;

		add(penguin);
	}

	public function addIcecream(ic : FlxSprite) : Void
	{
		if (icecream != null)
			icecream = null;
		
		icecream = ic;

		add(icecream);
	}
}