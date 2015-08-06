package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class WorldMapState extends FlxState
{
	public var mapName : String;

	public var nodes : Map<String, Node>;
	var numNodes : Int;
	
	public var currentNode : String;
	public var currentPath : Path;
	public var currentDir  : Int;
	
	public var cursor : FlxSprite;
	public var dirSelector : FlxSprite;
	
	public var map : TiledWorldMap;

	public function new(?MapName : String)
	{
		super();
		
		if (MapName == null)
			MapName = "" + GameController.GameStatus.currentWorld;
			
		mapName = MapName;
		
		nodes = new Map<String, Node>();
	}

	override public function create() : Void
	{
		// Load the tiled map
		map = new TiledWorldMap("assets/maps/world-" + mapName + ".tmx");
	
		// Add tilemaps
		add(map.backgroundTiles);
		
		// Load map objects
		map.loadObjects(this);
	
		// Load map, read nodes and paths and such
		// generateMap();
		
		// Add entities
		var nodesIt : Iterator<Node> = nodes.iterator();
		while (nodesIt.hasNext())
			add(nodesIt.next());
			
		cursor = new FlxSprite(0, 0).makeGraphic(8, 8, 0xFFCC03AA);
		add(cursor);
		FlxG.camera.follow(cursor);
		
		updateCursorPosition();
		
		dirSelector = new FlxSprite(4, 4).makeGraphic(2, 2, 0xFF0303FF);
		add(dirSelector);
		
		// Add overlay tiles
		add(map.overlayTiles);
	}
	
	override public function destroy()
	{
		map.destroy();
		map = null;
	}
	
	override public function update()
	{
		if (FlxG.keys.anyJustReleased(["ENTER"]))
			FlxG.switchState(new PrelevelState());
	
		// Only allow movement if we are not moving
		if (currentPath == null)
		{
			// Enter level
			if (FlxG.keys.anyJustReleased(["A"]))
			{
				var cNode : Node = nodes.get(currentNode);
				
				if (cNode.levelFile != null)
				{
					// Store the current level
					GameController.GameStatus.currentLevel = cNode.levelFile;
					// Save
					GameController.save();
					// Go!
					FlxG.switchState(new PlayState(GameController.GameStatus.currentLevel));
				}
			}
		
			// Direction
			handleDirSelector();
			
			var direction : Int = FlxObject.NONE;
			if (FlxG.keys.anyJustReleased(["Up"])) direction = FlxObject.UP;
			if (FlxG.keys.anyJustReleased(["Down"])) direction = FlxObject.DOWN;
			if (FlxG.keys.anyJustReleased(["Left"])) direction = FlxObject.LEFT;
			if (FlxG.keys.anyJustReleased(["Right"])) direction = FlxObject.RIGHT;
			
			if (direction != FlxObject.NONE && currentNode != null)
			{
				var cNode : Node = nodes.get(currentNode);
				var path : Path = cNode.paths.get(direction);
				if (path != null)
				{
					currentPath = path;
					var timeToWalk : Float = path.length() / 8 * 0.2;
					FlxTween.linearPath(cursor, path.nodes, timeToWalk, { complete: onPathFinished });
				}
			}
		}
	}
	
	function handleDirSelector() : Void
	{
		if (currentNode != null)
		{
			// If direction change button pressed
			// Find next allowed direction
				// The allowed directions are in nodes.get(currentNode)
			// Change to it
		}
	}
	
	public function onPathFinished(Tween : FlxTween) : Void
	{
		if (currentPath != null)
		{
			currentNode = currentPath.pointB.name;
			updateCursorPosition();
			
			currentPath = null;
		}
	}
	
	public function updateCursorPosition()
	{
		if (currentNode != null) 
		{
			var cNode : Node = nodes.get(currentNode);
			if (cNode != null)
			{
				cursor.x = cNode.x;
				cursor.y = cNode.y;
				
				// Debug directions
				trace("Directions from " + cNode.name + ":");
				for (dir in [FlxObject.UP, FlxObject.RIGHT, FlxObject.DOWN, FlxObject.LEFT])
				{
					if (cNode.paths.get(dir) != null)
						trace("  - " + dirName(dir) + ": " + cNode.paths.get(dir).pointB.name);
				}
				
				currentDir = getAllowedDirections()[0];
			}
		}		
		
	}
	
	function getAllowedDirections() : Array<Int>
	{
		var allowedDirections : Array<Int> = new Array<Int>();
			
		var cNode : Node = nodes.get(currentNode);
		var cNodeDirsIterator : Iterator<Int> = cNode.paths.keys();
		while (cNodeDirsIterator.hasNext())
		{
			allowedDirections.push(cNodeDirsIterator.next());
		}
		
		return allowedDirections;
	}
	
	/* Generation utils */
	
	function generateMap() : Void
	{
		numNodes = 0;
		generateNode("0", new FlxPoint(160, 70));
		currentNode = "0";
	}
	
	function generateNode(name : String, ?pos : FlxPoint, ?fromPath : Path) : Node
	{
		if (pos == null) 
		{
			pos = new FlxPoint();
			pos.x = FlxRandom.intRanged(0, 320);
			pos.y = FlxRandom.intRanged(0, 140);
		}
		
		trace("New node '" + name + "' at (" + pos.x + ", " + pos.y + ")");
		
		var node : Node = new Node(Std.int(pos.x), Std.int(pos.y), name);
		nodes.set(name, node);
		
		// Set the return path if we are coming from somewhere
		if (fromPath != null)
		{
			var returnPath : Path = fromPath.inverse();
			node.paths.set(returnPath.directionA, returnPath);
			trace("(" + node.name + ") ==[" + dirName(returnPath.directionA) + "]=> (" + returnPath.pointB.name + ")");
		}
		
		if (numNodes++ > 6)
			return node;
			
		// Generate destinies and paths
		var numTargets = FlxRandom.intRanged(0, 3);
		trace("  - with " + numTargets + " paths");
		for (i in 0...numTargets)
		{
			var path : Path = generatePath(node);
			var newNode = generateNode(name + "-" + i, path.nodes[path.nodes.length-1], path);
			path.pointB = newNode;
			trace("(" + node.name + ") ==[" + dirName(path.directionA) + "]=> ("+ newNode.name + ")");
		}
		
		return node;
	}
	
	function generatePath(from : Node) : Path
	{
		var path : Path = null;
		
		// Choose a random direction to build the path
		var directions : Array<Int> = FlxRandom.shuffleArray([FlxObject.UP, FlxObject.DOWN, FlxObject.LEFT, FlxObject.RIGHT], 12);
		for (dir in directions)
		{
			if (from.paths.get(dir) == null)
			{
				path = makePathFrom(from, dir);				
				from.paths.set(dir, path);
				trace("Generated path from " +  from.name + " " + dirName(dir) + "-wards");
				break;
			}
		}
		
		return path;
	}
	
	function makePathFrom(from : Node, direction : Int) : Path
	{
		var path : Path = new Path(from);
		path.directionA = direction;
	
		var point : FlxPoint = new FlxPoint(from.x, from.y);
		// Add the initial point (so we have at least 2 points
		path.nodes.push(point);
		
		for (i in 0...FlxRandom.intRanged(1, 3))
		{
			var newPoint : FlxPoint = new FlxPoint();
			
			newPoint.x = point.x;
			newPoint.y = point.y;
			
			switch (direction)
			{
				case FlxObject.LEFT:
					newPoint.x -= FlxRandom.intRanged(32, 64);
					for (xx in Std.int(newPoint.x)...Std.int(point.x))
						if (xx % 2 == 0)
							add(new FlxSprite(xx + 4, newPoint.y + 4).makeGraphic(1, 1, 0xFFAAAAAA));
				case FlxObject.RIGHT:
					newPoint.x += FlxRandom.intRanged(32, 64);
					for (xx in Std.int(point.x)...Std.int(newPoint.x))
						if (xx % 2 == 0)
							add(new FlxSprite(xx + 4, newPoint.y + 4).makeGraphic(1, 1, 0xFFAAAAAA));
				case FlxObject.UP:
					newPoint.y -= FlxRandom.intRanged(32, 64);
					for (yy in Std.int(newPoint.y)...Std.int(point.y))
						if (yy % 2 == 0)
							add(new FlxSprite(newPoint.x + 4, yy + 4).makeGraphic(1, 1, 0xFFAAAAAA));
				case FlxObject.DOWN:
					newPoint.y += FlxRandom.intRanged(32, 64);
					for (yy in Std.int(point.y)...Std.int(newPoint.y))
						if (yy % 2 == 0)
							add(new FlxSprite(newPoint.x + 4, yy + 4).makeGraphic(1, 1, 0xFFAAAAAA));
			}
			
			
			
			path.nodes.push(newPoint);
			path.directionB = inverseDir(direction);
			
			// Avoid 180degree turns
			direction = FlxRandom.getObject(dirsWithout(inverseDir(direction)));
			
			point = newPoint;
		}
		
		return path;
	}
	
	public static function dirsWithout(Dir : Int) : Array<Int>
	{
		var dirs : Array<Int> = [FlxObject.UP, FlxObject.DOWN, FlxObject.LEFT, FlxObject.RIGHT];
		dirs.remove(Dir);
		return dirs;
	}
	
	public static function dirName(Dir : Int) : String
	{
		switch (Dir)
		{
			case FlxObject.LEFT:
				return "W";
			case FlxObject.RIGHT:
				return "E";
			case FlxObject.UP:
				return "N";
			case FlxObject.DOWN:
				return "S";
			default:
				return "?";
		}
	}
	
	public static function encodeDirName(Dir : String) : Int
	{
		switch (Dir)
		{
			case "W":
				return FlxObject.LEFT;
			case "E":
				return FlxObject.RIGHT;
			case "N":
				return FlxObject.UP;
			case "S":
				return FlxObject.DOWN;
			default:
				return -1;
		}
	}
	
	public static function inverseDir(Dir : Int) : Int
	{
		switch (Dir)
		{
			case FlxObject.LEFT:
				return FlxObject.RIGHT;
			case FlxObject.RIGHT:
				return FlxObject.LEFT;
			case FlxObject.UP:
				return FlxObject.DOWN;
			case FlxObject.DOWN:
				return FlxObject.UP;
			default:
				return FlxObject.NONE;
		}
	}
}
