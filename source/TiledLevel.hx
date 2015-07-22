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

	public function new(tiledLevel : Dynamic)
	{
		super(tiledLevel);

		overlayTiles = new FlxGroup();
		foregroundTiles = new FlxGroup();
		backgroundTiles = new FlxGroup();

		FlxG.camera.setBounds(0, 0, fullWidth, fullHeight, true);

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
				trace("Found overlay");
			}
			else if (tileLayer.properties.contains("nocollide")) 
			{
				trace("Found non-collidable layer");
				backgroundTiles.add(tilemap);
			}
			else
			{
				trace("Found collision layer");
				if (collidableTileLayers == null)
					collidableTileLayers = new Array<FlxTilemap>();

				collidableTileLayers.push(tilemap);
			}
		}

	}

	public function loadObjects(state : PlayState)
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

		if (o.gid != -1) {
			y -= g.map.getGidOwner(o.gid).tileHeight;
			trace("Up with " + o.gid + " by " + g.map.getGidOwner(o.gid).tileHeight);
		}

		switch (o.type.toLowerCase()) 
		{
			case "start":
				addPenguin(x, y, state);
			case "fire": 
				/*var tileset = g.map.getGidOwner(o.gid);
				trace(o.gid);
				var fire = new FlxSprite(x, y).makeGraphic(16, 16, 0xDDAA0101);
				state.add(fire);*/
				var fire : FireHazard = new FireHazard(x, y, state);
				state.hazards.add(fire);
			case "drop":
				var hazardTypeStr : String = o.custom.get("hType");
				var hazardType : Hazard.HazardType;

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
						hazardType = Hazard.HazardType.Collision;
				}

				var droplet : DropHazard = new DropHazard(x, y, state, hazardType, new FlxPoint(o.width, o.height));
				state.hazards.add(droplet);
			case "ball":
			case "rock":
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
			case "bumper":
				var bumper : EBumper = new EBumper(x, y, state);
				state.enemies.add(bumper);
			case "runner":
				var runner : EnemyRunner = new EnemyRunner(x, y, state);
				state.enemies.add(runner);
		}
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