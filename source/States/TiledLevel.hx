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

		FlxG.camera.setBounds(0, 0, fullWidth, fullHeight, true);

		/* Read config info */
		var strMps : String = properties.get("MPS");
		if (strMps != null)
			meltingsPerSecond = Std.parseFloat(strMps);
		else
			meltingsPerSecond = null;
		
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
			
			if (tileLayer.properties.contains("overlay"))
			{
				overlayTiles.add(tilemap);
				// trace("Found overlay");
			}
			else if (tileLayer.properties.contains("nocollide")) 
			{
				// trace("Found non-collidable layer");
				backgroundTiles.add(tilemap);
			}
			else
			{
				// trace("Found collision layer");
				if (collidableTileLayers == null)
					collidableTileLayers = new Array<FlxTilemap>();

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
			// y -= g.map.getGidOwner(o.gid).tileHeight;
			// trace("Up with " + o.gid + " by " + g.map.getGidOwner(o.gid).tileHeight);
			y -= o.height;
			// trace("Up with " + o.gid + " by " + o.height);
		}

		switch (o.type.toLowerCase()) 
		{
			case "start":
				addPenguin(x, y, state);
		
		/** Elements **/
			case "goal":
				var type : Int = Std.parseInt(o.custom.get("type"));
				var goal : LevelGoal = new LevelGoal(x, y, type);
				state.levelGoals.add(goal);
			case "water":
				var water : FlxSprite = new FlxSprite(x, y);
				water.makeGraphic(o.width, o.height, 0x440110CC);
				water.setSize(o.width, o.height);
				water.centerOrigin();
				state.watery.add(water);
			case "oneway":
				var oneway : FlxObject = new FlxObject(x, y, o.width, o.height);
				oneway.allowCollisions = FlxObject.UP;
				oneway.immovable = true;
				state.oneways.add(oneway);
				
		/** Hazards **/
			case "fire": 
				var fire : FireHazard = new FireHazard(x, y, state);
				state.hazards.add(fire);
			case "drop":
				var hazardType : Hazard.HazardType = getHType(o);
				var waitTime   : Float = null;
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
				
				var gusher : GushingHazard = new GushingHazard(x, y + o.height, state, hazardType);
				gusher.configure(idleTime, activeTime, startupTime, inverse);
				state.hazards.add(gusher);
			case "ball":
			case "rock":
			
		/** Enemies **/
			case "bumper":
				var bumper : EBumper = new EBumper(x, y, state);

				state.enemies.add(bumper);
			case "runner":
				var jumper : Bool = o.custom.contains("jumper");
				var runner : EnemyRunner = new EnemyRunner(x, y, state, jumper);
				initEnemy(runner, o);
				state.enemies.add(runner);
			case "walker": 
				var hazardType : Hazard.HazardType = getHType(o);
				var walker : EnemyWalker = new EnemyWalker(x, y, state);
				initEnemy(walker, o);
				walker.hazardType = hazardType;
				state.enemies.add(walker);
			case "parashooter":
				var parashooter : EnemyParashooter = new EnemyParashooter(x, y, state);
				initEnemy(parashooter, o);
				state.enemies.add(parashooter);
			case "walkshooter":
				var hazardType : Hazard.HazardType = getHType(o);
				var walkShooter : EnemyWalkShooter = new EnemyWalkShooter(x, y, state);
				initEnemy(walkShooter, o);
				walkShooter.hazardType = hazardType;
				state.enemies.add(walkShooter);
			case "fly":
				var world : Int = getWorld(o);
				var fly : EnemyBurstFly = new EnemyBurstFly(x, y, state);
				initEnemy(fly, o);
				state.enemies.add(fly);
			case "slowfloater":
				var floater : EnemySlowFloater = new EnemySlowFloater(x, y, state);
				initEnemy(floater, o);
				state.enemies.add(floater);
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