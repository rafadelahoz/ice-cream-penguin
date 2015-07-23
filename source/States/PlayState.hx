package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.FlxCamera;
import flixel.tile.FlxTilemap;

using flixel.util.FlxSpriteUtil;

import flixel.system.scaleModes.PixelPerfectScaleMode;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	var fixedSM : PixelPerfectScaleMode;

	public var mapName : String;

	var deathManager : DeathManager;

	var camera : FlxCamera;

	public var penguin : Penguin;
	public var icecream : FlxSprite;

	public var ground : FlxGroup;
	public var level : TiledLevel;

	public var watery : FlxGroup;
	public var oneways : FlxGroup;

	public var enemies : FlxTypedGroup<Enemy>;
	public var hazards : FlxGroup;
		public var mobileHazards : FlxTypedGroup<Hazard>;

	public var entities : FlxTypedGroup<Entity>;

	public function new(?Level : String)
	{
		super();

		if (Level == null)
			Level = "" + GameController.GameStatus.currentLevel;

		mapName = Level;
	}

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
		entities = new FlxTypedGroup<Entity>();

		icecream = null;
		watery = new FlxGroup();
		oneways = new FlxGroup();
		enemies = new FlxTypedGroup<Enemy>();
		hazards = new FlxGroup();
			mobileHazards = new FlxTypedGroup<Hazard>();
			hazards.add(mobileHazards);

		// Load the tiled level
		level = new TiledLevel("assets/maps/" + mapName + ".tmx");
		// Add tilemaps
		add(level.backgroundTiles);

		// Load level objects
		level.loadObjects(this);
		add(watery);
		add(enemies);
		add(hazards);

		// Add overlay tiles
		add(level.overlayTiles);

		// Set the camera to follow the penguin
		if (penguin != null)
			FlxG.camera.follow(penguin, FlxCamera.STYLE_PLATFORMER, null, 0);

		// Register the Virtual Pad
		add(Penguin.virtualPad);

		// Prepare death manager
		deathManager = DeathManager.get(this);

		// Delegate
		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		if (penguin != null) {
			penguin.destroy();
			penguin = null;
			icecream.destroy();
			icecream = null;
		}

		level.destroy();
		level = null;
		watery.destroy();
		watery = null;
		enemies.destroy();
		enemies = null;
		hazards.destroy();
		hazards = null;
		oneways.destroy();
		oneways = null;

		deathManager.destroy();
		deathManager = null;

		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		if (deathManager.onUpdate()) 
		{
			if (FlxG.keys.anyPressed(["K"])) {
				// FlxG.camera.shake(0.02, 0.05);
				DeathManager.get().onDeath("kill");
			}

			for (enemy in enemies)
				level.collideWithLevel(enemy);

			level.collideWithLevel(penguin);
			
			for (hazard in mobileHazards)
				level.collideWithLevel(hazard);
			
			FlxG.collide(oneways, penguin);
			FlxG.overlap(hazards, penguin, onHazardPlayerCollision);
			FlxG.overlap(watery, penguin, overlapWater);
			FlxG.overlap(enemies, penguin, onEnemyCollision);
			
			FlxG.collide(enemies, enemies); // Testing this one

			FlxG.overlap(hazards, icecream, onHazardIcecreamCollision);
			FlxG.overlap(enemies, icecream, onEnemyIcecreamCollision);	
		}

		super.update();
	}	

	override public function draw() : Void
	{
		super.draw();
		deathManager.onDraw();
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

	public function onHazardPlayerCollision(a : Hazard, b : Penguin)
	{
		b.onCollisionWithHazard(a);
		
		a.onCollisionWithPlayer(b);
	}

	public function onHazardIcecreamCollision(a : Hazard, b : Icecream)
	{
		b.onCollisionWithHazard(a);
		a.onCollisionWithIcecream(b);
	}
	
	public function onEnemyIcecreamCollision(a : Enemy, b : Icecream)
	{
		b.onCollisionWithEnemy(a);
		a.onCollisionWithIcecream(b);
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