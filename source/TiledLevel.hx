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

class TiledLevel extends TiledMap
{
	private inline static var tilesetPath = "assets/tilesets/";

	public var overlayTiles    : FlxGroup;
	public var foregroundTiles : FlxGroup;
	public var backgroundTiles : FlxGroup;
	private var collidableTileLayers : Array<FlxTilemap>;

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

			var imagePath = new Path(tileset.imageSource);
			var processedPath = tilesetPath + imagePath.file + "." + imagePath.ext;
			trace(processedPath);

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

	}

	private function loadObject(o : TiledObject, g : TiledObjectGroup, state : PlayState) : Void
	{

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
}