package;

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

class TiledWorldMap extends TiledMap
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
		collidableTileLayers = new Array<FlxTilemap>();

		FlxG.camera.setBounds(0, 0, fullWidth, fullHeight, true);

		/* Read config info */
		
		/* Read tile info */
		for (tileLayer in layers)
		{
			var tilesetName : String = tileLayer.properties.get("tileset");
			trace(tilesetName);
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
				trace("Found overlay");
				overlayTiles.add(tilemap);
			}
			else if (tileLayer.properties.contains("collide")) 
			{
				trace("Found collidable");
				collidableTileLayers.push(tilemap);
			}
			else 
			{
				trace("Found tilemap");
				backgroundTiles.add(tilemap);
			}
			
		}

	}

	public function loadObjects(state : WorldMapState) : Void
	{
		var paths : Array<TempPath> = new Array<TempPath>();
		
		for (group in objectGroups)
		{
			for (o in group.objects)
			{
				loadObject(o, group, state, paths);
			}
		}
		
		// Process temporal paths now that all the nodes are available
		for (tpath in paths)
		{
			// Locate nodes
			var fromNode : Node = state.nodes.get(tpath.from);
			var toNode : Node = state.nodes.get(tpath.to);
			
			if (fromNode == null)
				trace("Origin node " + fromNode + " not found");
			if (toNode == null)
				trace("Target node " + toNode + " not found");
		
			absolutePointPositions(tpath.points, fromNode);
		
			var path : Path = new Path(tpath.points, fromNode, toNode, tpath.fromDir, tpath.toDir);
			fromNode.paths.set(tpath.fromDir, path);
			toNode.paths.set(tpath.toDir, path.inverse());
		}

	}

	private function loadObject(o : TiledObject, g : TiledObjectGroup, state : WorldMapState, paths : Array<TempPath>) : Void
	{
		var x : Int = o.x;
		var y : Int = o.y;

		// The Y position of objects created from tiles must be corrected by the object height
		if (o.gid != -1) {
			y -= o.height;
		}

		switch (o.type.toLowerCase()) 
		{
			case "path":
				var points : Array<FlxPoint> = o.points;
				
				for (point in points)
					point.add(x, y);
				
				var from : String = o.custom.get("from");
				var to : String = o.custom.get("to");
				
				var tempPath : TempPath = { 
					points : points, 
					from : extractPathNodeName(from), 
					to: extractPathNodeName(to),
					fromDir : extractPathNodeDir(from),
					toDir : extractPathNodeDir(to)
				};
				
				paths.push(tempPath);
				
			case "node":
				var levelFile : String = o.custom.get("file");
				
				var node : Node = new Node(x, y, o.name, levelFile);
				state.nodes.set(o.name, node);
				
				if (o.custom.contains("initial"))
					state.currentNode = o.name;
			default:
		}
	}
	
	/**
	* Updates the provided array of relative FlxPoints by offsetting with the from node position
	*/ 
	function absolutePointPositions(points : Array<FlxPoint>, from : Node) : Void
	{
		// Fetch node origin
		var node : FlxPoint = new FlxPoint(from.x, from.y);
		
		/*for (point in points)
		{
			point.add(node.x, node.y);
		}*/
		
		// The node might be the first or the last one of the array
		var first : FlxPoint = points[0];
		var last : FlxPoint = points[points.length-1];
		
		if (node.distanceTo(last) < node.distanceTo(first))
		{
			trace("Reversing " + points);
			points.reverse();
		}
	}
	
	/**
	* Returns the node name contained in the provided path endpoint string structure
	* @param str Endpoint String structure in form <Dir>@<Name>
	*/
	function extractPathNodeName(str : String) : String
	{
		return str.substring(2);
	}
	
	/**
	* Returns the direction code of the direction name contained in the
	* provided path endpoint string structure
	* @param str Endpoint String structure in form <Dir>@<Name>
	*/
	function extractPathNodeDir(str : String) : Int
	{
		var dirStr : String = str.substring(0, 1);
		return WorldMapState.encodeDirName(dirStr);
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
		var imagePath = new haxe.io.Path(tileset.imageSource);
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

typedef TempPath = { 
	points : Array<FlxPoint>, 
	from : String, 
	to : String, 
	fromDir : Int, 
	toDir : Int
};