package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.FlxCamera;
import flixel.tile.FlxTilemap;

import flixel.system.scaleModes.PixelPerfectScaleMode;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	var fixedSM : PixelPerfectScaleMode;

	var deathManager : DeathManager;

	var camera : FlxCamera;

	public var penguin : Penguin;
	public var icecream : FlxSprite;

	public var ground : FlxGroup;
	public var level : TiledLevel;

	public var watery : FlxGroup;
	public var oneways : FlxGroup;

	public var enemies : FlxTypedGroup<Enemy>;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.debugger.visible = true;
		FlxG.log.redirectTraces = true;

		fixedSM = new PixelPerfectScaleMode();
		FlxG.scaleMode = fixedSM;

		// Prepare state holders
		icecream = null;
		watery = new FlxGroup();
		oneways = new FlxGroup();
		enemies = new FlxTypedGroup<Enemy>();

		// Load the tiled level
		level = new TiledLevel("assets/maps/6.tmx");
		// Add tilemaps
		add(level.backgroundTiles);

		// Load level objects
		level.loadObjects(this);
		add(watery);
		add(enemies);

		// Add overlay tiles
		add(level.overlayTiles);

		// Set the camera to follow the penguin
		if (penguin != null)
			FlxG.camera.follow(penguin, FlxCamera.STYLE_PLATFORMER, null, 0);

		// Register the Virtual Pad
		add(Penguin.virtualPad);

		// Prepare death manager
		deathManager = new DeathManager();

		// Delegate
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
		if (deathManager.update()) 
		{
			if (FlxG.keys.anyPressed(["ENTER"])) {
				FlxG.camera.shake(0.02, 0.05);
			}

			for (enemy in enemies)
				level.collideWithLevel(enemy);

			level.collideWithLevel(penguin);

			FlxG.collide(oneways, penguin);

			FlxG.overlap(watery, penguin, overlapWater);

			FlxG.overlap(enemies, penguin, onEnemyCollision);
		}
		
		super.update();
	}	

	override public function draw() : Void
	{
		deathManager.draw();
		super.draw();
	}

	public function overlapWater(water : FlxObject, entity : FlxObject) : Void
	{
		if (Std.is(entity, Penguin)) 
		{
			(cast(entity, Penguin)).onEnterWater(water);
			// entity.velocity.y -= water.height - (water.y - entity.y - 16) / water.height * 1.0;
		}
		else 
		{
			trace("Something is trying to float: " + entity);
		}
	}

	public function onEnemyCollision(one : Enemy, two : Penguin) : Void
	{
		FlxObject.separate(one, two);
		one.onCollisionWithPlayer(two);
		two.onCollisionWithEnemy(one);
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