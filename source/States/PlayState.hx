package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.FlxCamera;
import flixel.tile.FlxTilemap;
import flixel.util.FlxTimer;
import flixel.util.FlxPoint;
using flixel.util.FlxSpriteUtil;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	/* Level config */
	public var mapName : String;
	public var meltingsPerSecond : Float;
	
	/* General elements */
	var playflowManager : PlayFlowManager;
	var camera : FlxCamera;
	var gui : GUI;
	var mpsTimer : FlxTimer;
	public var currentMps : Float;

	/* Entities lists */
	public var penguin : Penguin;
	public var icecream : Icecream;

	public var level : TiledLevel;

	public var watery : FlxGroup;
	public var oneways : FlxGroup;

	public var enemies : FlxTypedGroup<Enemy>;
	public var hazards : FlxGroup;
	public var mobileHazards : FlxGroup;

	public var collectibles : FlxTypedGroup<Collectible>;
	public var levelGoals : FlxTypedGroup<LevelGoal>;

	// General entities list for pausing
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
		// FlxG.debugger.visible = true;
		// FlxG.log.redirectTraces = true;

		// Prepare state holders
		entities = new FlxTypedGroup<Entity>();

		penguin = null;
		icecream = null;

		watery = new FlxGroup();
		oneways = new FlxGroup();
		
		enemies = new FlxTypedGroup<Enemy>();
		
		hazards = new FlxGroup();
		mobileHazards = new FlxGroup();
		hazards.add(mobileHazards);

		collectibles = new FlxTypedGroup<Collectible>();
		levelGoals = new FlxTypedGroup<LevelGoal>();

		// Load the tiled level
		level = new TiledLevel("assets/maps/" + mapName + ".tmx");
		
		/* Read level parameters */
		// MPS (Meltings per second)
		meltingsPerSecond = level.meltingsPerSecond;
		// Default 1.6 if not specified (icecream melt in 1 minute)
		if (meltingsPerSecond == null)
			meltingsPerSecond = 1.6;
		
		currentMps = meltingsPerSecond;
		mpsTimer = new FlxTimer(1, handleMeltingsPerSecond, 0);
		
		// Add tilemaps
		add(level.backgroundTiles);

		// Load level objects
		level.loadObjects(this);

		add(levelGoals);
		
		add(penguin);
		add(icecream);
		
		add(collectibles);
		
		add(enemies);
		add(hazards);

		add(watery);

		// Add overlay tiles
		add(level.overlayTiles);

		// Set the camera to follow the penguin
		if (penguin != null)
			FlxG.camera.follow(penguin, FlxCamera.STYLE_PLATFORMER, null, 0);

		// Add the GUI
		gui = new GUI();
		add(gui);
			
		// Register the Virtual Pad
		// add(Penguin.virtualPad);

		// Prepare death manager
		playflowManager = PlayFlowManager.get(this);

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
		mobileHazards.destroy();
		mobileHazards = null;
		hazards.destroy();
		hazards = null;
		oneways.destroy();
		oneways = null;
		levelGoals.destroy();
		levelGoals = null;
		collectibles.destroy();
		collectibles = null;
		
		gui.destroy();
		gui = null;

		playflowManager.destroy();
		playflowManager = null;

		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		if (playflowManager.onUpdate()) 
		{
			if (FlxG.keys.anyPressed(["K"])) {
				// FlxG.camera.shake(0.02, 0.05);
				PlayFlowManager.get().onDeath("kill");
			}

			if (FlxG.keys.anyJustPressed(["UP"]))
				FlxG.timeScale = Math.min(FlxG.timeScale + 0.5, 1);
			else if (FlxG.keys.anyJustPressed(["DOWN"]))
				FlxG.timeScale = Math.max(FlxG.timeScale - 0.5, 0);
			
			for (enemy in enemies)
			{
				if (enemy.collideWithLevel)
					level.collideWithLevel(enemy);
			}

			level.collideWithLevel(penguin);
			
			for (hazard in mobileHazards)
			{
				if ((cast hazard).collideWithLevel)
					level.collideWithLevel(cast hazard);
			}
			
			FlxG.overlap(collectibles, penguin, onCollectibleCollision);
			FlxG.collide(oneways, penguin);
			FlxG.overlap(hazards, penguin, onHazardPlayerCollision);
			FlxG.overlap(watery, penguin, overlapWater);
			FlxG.overlap(enemies, penguin, onEnemyCollision);
			
			FlxG.collide(enemies/*, enemies*/); // Testing this one

			FlxG.overlap(hazards, icecream, onHazardIcecreamCollision);
			FlxG.overlap(enemies, icecream, onEnemyIcecreamCollision);	

			FlxG.overlap(levelGoals, penguin, onLevelGoalCollision);
			
			gui.updateGUI(icecream, this);
		}
		
		if (FlxG.mouse.justPressed)
		{
			var mousePos : FlxPoint = FlxG.mouse.getWorldPosition();
			collectibles.add(new IceShard(mousePos.x, mousePos.y, this));
		}

		super.update();
	}

	override public function draw() : Void
	{
		super.draw();
		playflowManager.onDraw();
	}
	
	public function handleMeltingsPerSecond(timer : FlxTimer) : Void
	{
		// Called every second to handle icecream melting by environment
		icecream.makeHotter(currentMps);
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

	public function onCollectibleCollision(collectible : Collectible, pen : Penguin)
	{
		collectible.onCollisionWithPlayer(pen);
		// Don't notify the penguin for now
	}
	
	public function onLevelGoalCollision(goal : LevelGoal, pen : Penguin)
	{
		playflowManager.onGoal();
	}

	public function addPenguin(p : Penguin) : Void
	{
		if (penguin != null)
			penguin = null;

		penguin = p;

		// add(penguin);
	}

	public function addIcecream(ic : Icecream) : Void
	{
		if (icecream != null)
			icecream = null;
		
		icecream = ic;

		// add(icecream);
	}
}