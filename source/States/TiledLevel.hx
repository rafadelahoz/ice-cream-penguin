package;

import haxe.io.Path;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.FlxSprite;
import flixel.util.FlxPoint;

class TiledLevel extends TiledMap
{
	private inline static var spritesPath = "assets/images/";
	private inline static var tilesetPath = "assets/tilesets/";

	public var overlayTiles    : FlxGroup;
	public var foregroundTiles : FlxGroup;
	public var backgroundTiles : FlxGroup;
	public var collidableTileLayers : Array<FlxTilemap>;
	
	public var meltingsPerSecond : Float;

	public function new(tiledLevel : Dynamic)
	{
		super(tiledLevel);

		overlayTiles = new FlxGroup();
		foregroundTiles = new FlxGroup();
		backgroundTiles = new FlxGroup();
		collidableTileLayers = new Array<FlxTilemap>();

		FlxG.camera.setBounds(0, 0, fullWidth, fullHeight, true);

		/* Read config info */
		var strMps : String = properties.get("MPS");
		if (strMps != null)
			meltingsPerSecond = Std.parseFloat(strMps);
		else
			meltingsPerSecond = -1;
		
		/* Read tile info */
		for (tileLayer in layers)
		{
			var tilesetName : String = tileLayer.properties.get("tileset");
			if (tilesetName == null)
				throw "'tileset' property not defined for the " + tileLayer.name + " layer. Please, add the property to the layer.";

			// Locate the tileset
			var tileset : TiledTileSet = null;
			for (ts in tilesets) {
				if (ts.name == tilesetName) 
				{
					tileset = ts;
					break;
				}
			}

			// trace(tilesetName);

			if (tileset == null)
				throw "Tileset " + tilesetName + " could not be found. Check the name in the layer 'tileset' property or something.";

			var processedPath = buildPath(tileset);

			var tilemap : FlxTilemap = new FlxTilemap();
			tilemap.widthInTiles = width;
			tilemap.heightInTiles = height;
			tilemap.loadMap(tileLayer.tileArray, processedPath, tileset.tileWidth, tileset.tileHeight, 0, 1, 1, 1);
			
			tilemap.ignoreDrawDebug = true;
			
			if (tileLayer.properties.contains("overlay"))
			{
				overlayTiles.add(tilemap);
			}
			else if (tileLayer.properties.contains("nocollide")) 
			{
				backgroundTiles.add(tilemap);
			}
			else
			{
				collidableTileLayers.push(tilemap);
			}
		}

	}

	public function loadObjects(state : PlayState) : Void
	{
		for (group in objectGroups)
		{
			for (o in group.objects)
			{
				loadObject(o, group, state);
			}
		}

		if (state.penguin == null)
			addPenguin(64, 64, state);

	}

	private function loadObject(o : TiledObject, g : TiledObjectGroup, state : PlayState) : Void
	{
		var x : Int = o.x;
		var y : Int = o.y;

		// The Y position of objects created from tiles must be corrected by the object height
		if (o.gid != -1) {
			y -= o.height;
		}

		switch (o.type.toLowerCase()) 
		{
			case "start":
				addPenguin(x, y, state);
		
		/** Collectibles **/
			case "ice":
				var iceShard : IceShard = new IceShard(x, y, state);
				state.collectibles.add(iceShard);
		
		/** Elements **/
			case "goal":
				var type : Int = 0;
				if (o.custom.contains("type"))
					type = Std.parseInt(o.custom.get("type"));
				var unlocks : String = o.custom.get("unlocks");
				var goal : LevelGoal = new LevelGoal(x, y, type, unlocks);
				state.levelGoals.add(goal);
			case "water":
				var water : CleanWater = new CleanWater(x, y, o.width, o.height, state);
				state.watery.add(water);
			case "deepwater":
				var water : DeepWater = new DeepWater(x, y, o.width, o.height, state);
				state.watery.add(water);
			case "oneway":
				var oneway : FlxObject = new FlxObject(x, y, o.width, o.height);
				oneway.allowCollisions = FlxObject.UP;
				oneway.immovable = true;
				state.oneways.add(oneway);
				
		/** Hazards **/
			case "lava":
				var lava : LavaPool = new LavaPool(x, y, o.width, o.height, state);
				state.hazards.add(lava);
				
				// Lava pools have a hot zone over them by default
				// unless their manualTemperature flag is set
				if (!o.custom.contains("manualTemperature"))
				{
					var hotZoneHeight : Int = Std.int(Math.max(o.height, 64));
					var hotZone : TemperatureZone = new TemperatureZone(x, y - hotZoneHeight, o.width, hotZoneHeight);
					hotZone.setMultiplierMPS(GameConstants.LavaMpsMultiplier);
					state.temperatureZones.add(hotZone);
				}
				
			case "fire": 
				var fire : FireHazard = new FireHazard(x, y, state);
				state.hazards.add(fire);
			case "drop":
				var hazardType : Hazard.HazardType = getHType(o);
				var waitTime   : Float = -1;
				if (o.custom.contains("wait"))
					waitTime = Std.parseFloat(o.custom.get("wait"));
				var dropper : DropSpawner = new DropSpawner(x, y, state, waitTime, hazardType);
				state.hazards.add(dropper);
			case "gusher":
				var hazardType : Hazard.HazardType = getHType(o);
				var inverse		: Bool = o.custom.contains("inverse");
				var idleTime 	: Float = Std.parseFloat(o.custom.get("idle"));
				var activeTime 	: Float = Std.parseFloat(o.custom.get("active"));
				var startupTime	: Float = Std.parseFloat(o.custom.get("startup"));
				
				var gusher : Dynamic = null;
				if (hazardType == Hazard.HazardType.Fire)
					gusher = new FlameHazard(x, y + o.height, state, hazardType);
				else
				 	gusher = new GushingHazard(x, y + o.height, state, hazardType);
				gusher.configure(idleTime, activeTime, startupTime, inverse);
				state.hazards.add(gusher);
			case "surprise":
				var surprise : SurpriseDropHazard = new SurpriseDropHazard(x, y, state, Hazard.HazardType.Collision);
				state.mobileHazards.add(surprise);
			case "temperature":
				var tzone : TemperatureZone = new TemperatureZone(x, y, o.width, o.height);
				if (o.custom.contains("mps"))
				{
					var mps : Float = Std.parseFloat(o.custom.get("mps"));
					tzone.setSpecificMPS(mps);
				}
				else if (o.custom.contains("factor"))
				{
					var factor : Float = Std.parseFloat(o.custom.get("factor"));
					tzone.setMultiplierMPS(factor);
				}
				else
					tzone = null;
					
				if (tzone != null)
					state.temperatureZones.add(tzone);
			
		/** Enemies **/
			case "runner":
				var jumper : Bool = o.custom.contains("jumper");
				var runner : EnemyRunner = new EnemyRunner(x, y, state, jumper);
				initEnemy(runner, o);
				state.addEnemy(runner);
			case "walker": 
				var hazardType : Hazard.HazardType = getHType(o);
				var walker : EnemyWalker = new EnemyWalker(x, y, state);
				initEnemy(walker, o);
				walker.hazardType = hazardType;
				state.addEnemy(walker);
			case "parashooter":
				var parashooter : EnemyParashooter = new EnemyParashooter(x, y, state);
				initEnemy(parashooter, o);
				state.addEnemy(parashooter);
			case "walkshooter":
				var hazardType : Hazard.HazardType = getHType(o);
				var walkShooter : EnemyWalkShooter = new EnemyWalkShooter(x, y, state);
				initEnemy(walkShooter, o);
				walkShooter.hazardType = hazardType;
				state.addEnemy(walkShooter);
			case "hopper":
				var hazardType : Hazard.HazardType = getHType(o);
				var hopper : EnemyHopper = new EnemyHopper(x, y, state);
				initEnemy(hopper, o);
				state.addEnemy(hopper);
			case "jumpshooter":
				var jumpshooter : EnemyJumpShooter = new EnemyJumpShooter(x, y, state);
				jumpshooter.canShoot = true;
				initEnemy(jumpshooter, o);
				state.addEnemy(jumpshooter);
			case "fly":
				var world : Int = getWorld(o);
				var fly : EnemyBurstFly = new EnemyBurstFly(x, y, state);
				initEnemy(fly, o);
				state.addEnemy(fly);
			case "slowfloater":
				var floater : EnemySlowFloater = new EnemySlowFloater(x, y, state);
				initEnemy(floater, o);
				state.addEnemy(floater);
			case "vjumper":
				var vjumper : EnemyVerticalJumper = new EnemyVerticalJumper(x, y, state);
				
				if (o.custom.contains("idle"))
					vjumper.idleTime = Std.parseFloat(o.custom.get("idle"));
				if (o.custom.contains("speed"))
					vjumper.jumpSpeed = Std.parseFloat(o.custom.get("speed"));
					
				initEnemy(vjumper, o);
				state.addEnemy(vjumper);
				
			case "spawner":
				loadSpawner(o, state);
		}
	}
	
	private function loadSpawner(o : TiledObject, state : PlayState) : Void
	{
		var spawnee : String = o.custom.get("spawnee");
		var spawnTimeStr : String = o.custom.get("delay");
		var spawnTime : Float = 10;
		if (spawnTimeStr != null)
			spawnTime = Std.parseFloat(spawnTimeStr);
			
		switch (spawnee.toLowerCase())
		{
			case "flydrop":
				var spawner : EnemyFlyDropSpawner = new EnemyFlyDropSpawner(o.x, o.y, state, o.width, o.height, spawnTime);
				spawner.init();
				state.spawners.add(spawner);
				state.entities.add(spawner);
			case "hflame":
				var spawner : HorizontalFlameSpawner = new HorizontalFlameSpawner(o.x, o.y, state, o.width, o.height, spawnTime);
				spawner.init();
				state.spawners.add(spawner);
				state.entities.add(spawner);
			default:
				trace("wtf spawner?: " + spawnee);
		}
	}
	
	public function initEnemy(e : Enemy, o : TiledObject) : Void
	{
		var world : Int = getWorld(o);
		var variation : Int = getVariation(o);

		e.init(world, variation);
	}

	public function getWorld(o : TiledObject) : Int
	{
		var worldTypeStr : String = o.custom.get("class");
		
		switch (worldTypeStr)
		{
			case "Monster":
				return GameConstants.W_MONSTER;
			case "Ice":
				return GameConstants.W_ICE;
			case "Fire":
				return GameConstants.W_FIRE;
			case "Water":
				return GameConstants.W_WATER;
			default:
				return GameConstants.W_ANY;
		}
	}

	public function getVariation(o : TiledObject) : Int
	{
		var worldTypeStr : String = o.custom.get("variation");
		if (worldTypeStr != null)
			return Std.parseInt(worldTypeStr);
		else
			return 0;
	}

	public function getHType(o : TiledObject) : Hazard.HazardType
	{
		var hazardTypeStr : String = o.custom.get("hType");
		var hazardType : Hazard.HazardType = parseHazardType(hazardTypeStr);
		return hazardType;
	}
	
	public function parseHazardType(hazardTypeStr : String) : Hazard.HazardType
	{
		var hazardType : Hazard.HazardType = Hazard.HazardType.None;
		
		switch (hazardTypeStr)
		{
			case "Fire":
				hazardType = Hazard.HazardType.Fire;
			case "Water":
				hazardType = Hazard.HazardType.Water;
			case "Dirt":
				hazardType = Hazard.HazardType.Dirt;
			case "Collision":
				hazardType = Hazard.HazardType.Collision;
			default:
				hazardType = Hazard.HazardType.None;
		}
		
		return hazardType;
	}

	public function addPenguin(x : Int, y : Int, state : PlayState) : Void
	{
		var penguin : Penguin = new Penguin(x, y, state);

		state.addPenguin(penguin);
		state.addIcecream(penguin.getIcecream());
	}

	public function collideWithLevel(obj : FlxObject, ?notifyCallback : FlxObject -> FlxObject -> Void, ?processCallback : FlxObject -> FlxObject -> Bool) : Bool
	{
		if (collidableTileLayers != null)
		{
			for (map in collidableTileLayers) 
			{
				// Remember: Collide the map with the objects, not the other way around!
				return FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate);
			}
		}

		return false;
	}

	private function buildPath(tileset : TiledTileSet, ?spritesCase : Bool  = false) : String
	{
		var imagePath = new Path(tileset.imageSource);
		var processedPath = (spritesCase ? spritesPath : tilesetPath) + 
			imagePath.file + "." + imagePath.ext;

		return processedPath;
	}

	public function destroy() 
	{
		backgroundTiles.destroy();
		foregroundTiles.destroy();
		overlayTiles.destroy();
		for (layer in collidableTileLayers)
			layer.destroy();
	}
}