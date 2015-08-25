package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.FlxCamera;
import flixel.tile.FlxTilemap;
import flixel.util.FlxTimer;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxRandom;
using flixel.util.FlxSpriteUtil;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends GameState
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

	public var spawners : FlxTypedGroup<EnemySpawner>;
	
	public var enemies : FlxGroup;
		public var collidableEnemies : FlxGroup;
		public var nonCollidableEnemies : FlxGroup;
	public var hazards : FlxGroup;
	public var mobileHazards : FlxGroup;

	public var temperatureZones : FlxTypedGroup<TemperatureZone>;
	
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

		// Random Background color
		var bgColors = [0xFFBE3241, 0xFFDF7A92, 0xFF3EA5F2, 0xFF545454, 0xFF24323F, 0xFF6888FC, 0xFF3C565C, 0xFF529023, 0xFFA6CD33, 0xFFFFFFFF, 0xFFF7E176, 0xFF574A38, 0xFF463C2D, 0xFF352D22, 0xFF231E17, 0xFF120F0C];
		FlxG.camera.bgColor = bgColors[FlxRandom.intRanged(0, bgColors.length-1)];

		// Prepare state holders
		entities = new FlxTypedGroup<Entity>();

		penguin = null;
		icecream = null;

		watery = new FlxGroup();
		oneways = new FlxGroup();
		
		spawners = new FlxTypedGroup<EnemySpawner>();
		
		enemies = new FlxGroup();
			collidableEnemies = new FlxGroup();
			nonCollidableEnemies = new FlxGroup();
			enemies.add(collidableEnemies);
			enemies.add(nonCollidableEnemies);
		
		hazards = new FlxGroup();
		mobileHazards = new FlxGroup();
		hazards.add(mobileHazards);
		
		temperatureZones = new FlxTypedGroup<TemperatureZone>();

		collectibles = new FlxTypedGroup<Collectible>();
		levelGoals = new FlxTypedGroup<LevelGoal>();

		// Load the tiled level
		level = new TiledLevel("assets/maps/" + mapName + ".tmx");
		
		/* Read level parameters */
		// MPS (Meltings per second)
		meltingsPerSecond = level.meltingsPerSecond;
		// Default 1.6 if not specified (icecream melt in 1 minute)
		if (meltingsPerSecond == -1)
			meltingsPerSecond = GameConstants.DefaultMPS;
		
		currentMps = meltingsPerSecond;
		mpsTimer = new FlxTimer(0.1, handleMeltingsPerSecond, 0);
		
		// Add tilemaps
		add(level.backgroundTiles);

		// Load level objects
		level.loadObjects(this);

		add(levelGoals);
		
		add(spawners);
		
		add(enemies);

		add(penguin);
		add(icecream);

		add(hazards);
		
		add(temperatureZones);
		
		add(collectibles);

		add(watery);

		// Add overlay tiles
		add(level.overlayTiles);

		// Set the camera to follow the penguin
		if (penguin != null)
			FlxG.camera.follow(penguin, FlxCamera.STYLE_PLATFORMER, null, 0);

		// Add the GUI
		gui = new GUI();
		add(gui);
			
		// Prepare death manager
		playflowManager = PlayFlowManager.get(this, gui);

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
		spawners.destroy();
		spawners = null;
		collidableEnemies.destroy();
		collidableEnemies = null;
		nonCollidableEnemies.destroy();
		nonCollidableEnemies = null;
		enemies.destroy();
		enemies = null;
		mobileHazards.destroy();
		mobileHazards = null;
		hazards.destroy();
		hazards = null;
		temperatureZones.destroy();
		temperatureZones = null;
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
		/* If the game is not paused due to death, level finished, ... */
		if (playflowManager.onUpdate()) 
		{
			if (GamePad.justPressed(GamePad.Pause))
			{
				playflowManager.doPause();
			}
		
			/* Resolve collisions */
			// Enemies vs World
			resolveEnemiesWorldCollision();

			// Penguin vs World
			level.collideWithLevel(penguin);
			
			// Mobile hazards vs World
			mobileHazards.forEachOfType(Hazard, function(hazard : Hazard) : Void {
				level.collideWithLevel(hazard);
			});

			// Groups inside mobile hazards vs World
			mobileHazards.forEachOfType(FlxTypedGroup, function(hazardGroup : FlxTypedGroup<Hazard>) : Void {
				if (hazardGroup != null)
				{
					for (actualHazard in hazardGroup)
						if ((cast actualHazard).collideWithLevel)
							level.collideWithLevel(cast actualHazard);
				}
			});
			
			// Reset meltings per second (it will be modified on the next overlap)
			currentMps = meltingsPerSecond;
			
			// Penguin vs Temperature zones
			FlxG.overlap(temperatureZones, penguin, onPlayerOverTemperatureZone);
			
			// Penguin vs Collectibles
			FlxG.overlap(collectibles, penguin, onCollectibleCollision);
			// Penguin vs One way solids
			FlxG.collide(oneways, penguin);
			// Penguin vs Hazards
			FlxG.overlap(hazards, penguin, onHazardPlayerCollision);
			// Penguin vs Water
			FlxG.overlap(watery, penguin, overlapWater);
			// Penguin vs Enemies
			FlxG.overlap(enemies, penguin, onEnemyCollision);
			
			// Enemies vs enemies
			FlxG.collide(collidableEnemies);

			// Icecream vs Hazards
			FlxG.overlap(hazards, icecream, onHazardIcecreamCollision);
			// Icecream vs Enemies
			FlxG.overlap(enemies, icecream, onEnemyIcecreamCollision);	

			// Penguin vs Level Goal
			FlxG.overlap(levelGoals, penguin, onLevelGoalCollision);
			
			/* Update the GUI */
			gui.updateGUI(icecream, this);
		}
		else
		{
			if (GamePad.justPressed(GamePad.Pause))
				playflowManager.doUnpause();
		}
		
		/* Do the debug things */
		doDebug();

		/* Go on */
		super.update();
	}
	
	function resolveEnemiesWorldCollision() : Void
	{
		enemies.forEach(resolveEnemyWorldCollision);
		collidableEnemies.forEach(resolveEnemyWorldCollision);
		nonCollidableEnemies.forEach(resolveEnemyWorldCollision);
	}
	
	function resolveEnemyWorldCollision(enemy : FlxBasic) : Void
	{
		if ((cast enemy).collideWithLevel)
		{
			level.collideWithLevel((cast enemy));
		}
	}

	override public function draw() : Void
	{
		super.draw();
		playflowManager.onDraw();
	}
	
	public function handleMeltingsPerSecond(timer : FlxTimer) : Void
	{
		if (!playflowManager.paused)
		{
			// Called every second to handle icecream melting by environment
			icecream.makeHotter(currentMps * 0.1);
		}
	}

	public function overlapWater(water : FlxObject, entity : FlxObject) : Void
	{
		if (Std.is(entity, Penguin)) 
		{
			(cast(entity, Penguin)).onEnterWater(cast(water, Hazard));
		}
		else 
		{
			trace("Something is trying to float: " + entity);
		}
	}
	
	public function onPlayerOverTemperatureZone(zone : TemperatureZone, player : Penguin)
	{
		if (zone.isSpecific)
			currentMps = zone.mpsSpecific;
		else
		{
			// Multiplier only applies to hotter values
			var mps : Float = meltingsPerSecond;
			
			if (meltingsPerSecond <= 0)
				mps = GameConstants.DefaultMPS;
				
			currentMps = mps * zone.mpsMultiplier;
		}
		
	}

	public function onEnemyCollision(one : Enemy, two : Penguin) : Void
	{
		FlxObject.separate(one, two);
		one.onCollisionWithPlayer(two);
		two.onCollisionWithEnemy(one);
	}
	
	public function onEnemyEnemyCollision(a : Enemy, b : Enemy) : Void
	{
		trace("Colliding " + a + " and " + b);
		if (a.collideWithEnemies && b.collideWithEnemies)
			FlxObject.separate(a, b);
		else
			trace("NO COLL");
	}

	public function onHazardPlayerCollision(a : Hazard, b : Penguin)
	{
		// Notify the Penguin only if the hazard didn't handle the collision
		if (!a.onCollisionWithPlayer(b))
			b.onCollisionWithHazard(a);
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
		playflowManager.onGoal(goal);
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
	
	public function addEnemy(enemy : Enemy) : Void
	{
		if (enemy.collideWithEnemies)
			collidableEnemies.add(enemy);
		else
			nonCollidableEnemies.add(enemy);
	}
	
	function doDebug() : Void
	{
		if (FlxG.keys.anyPressed(["K"])) {
			// FlxG.camera.shake(0.02, 0.05);
			PlayFlowManager.get().onDeath("kill");
		}
		
		var mousePos : FlxPoint = FlxG.mouse.getWorldPosition();
		
		if (FlxG.mouse.justPressed)
		{
			// collectibles.add(new IceShard(mousePos.x, mousePos.y, this));
			// mobileHazards.add(new SurpriseDropHazard(mousePos.x, mousePos.y, this, Hazard.HazardType.Collision));
			
			/*var spotlightFx : SpotlightEffect = new SpotlightEffect();
			add(spotlightFx);

			PlayFlowManager.get().doPause();
			spotlightFx.close(mousePos, function() {
				PlayFlowManager.get().doUnpause();
				spotlightFx.cancel();
			});*/
		}
		
		if (FlxG.keys.anyJustPressed(["T"]))
		{
			penguin.x = Std.int(mousePos.x);
			penguin.y = Std.int(mousePos.y);
		}
		
		/*if (FlxG.keys.anyJustPressed(["UP"]))
			FlxG.timeScale = Math.min(FlxG.timeScale + 0.5, 1);
		else if (FlxG.keys.anyJustPressed(["DOWN"]))
			FlxG.timeScale = Math.max(FlxG.timeScale - 0.5, 0);*/
	}
}