package map;

import flixel.FlxState;
import flixel.util.FlxRandom;

class WorldMapState extends FlxState
{
	public var nodes : Map<String, Node>;
	
	public var currentNode : String;
	public var cursor : FlxSprite;

	public function new()
	{
		nodes = new Map<String, Node>();
	}

	override public function create() : Void
	{
		// Load map, read nodes and paths and such
		generateMap();
	}
	
	function generateMap() : Map<String, Node>
	{
		var nodes : Map<String, Node>();
		
		generateNode("0");
	}
	
	function generateNode(name : String, ?pos : FlxPoint) : Node
	{
		if (pos == null) 
		{
			pos = new FlxPoint();
			pos.x = FlxRandom.intRanged(0, 320);
			pos.y = FlxRandom.intRanged(0, 140);
		}
		
		var node : Node = new Node(pos.x, pos.y, name);
		nodes.put(name, node);
		
		// Generate destinies and paths
		var numTargets = FlxRandom.intRanged(0, 3);
		for (i in 0...numTargets)
		{
			var path : Path = generatePath(node);
			var newNode = generateNode(name + "-" + i, path.nodes.get(path.nodes.length-1));
			path.pointB = newNode;
		}
		
		return node;
	}
	
	function generatePath(from : Node) : Path
	{
		var path : Path = new Path(from);
		
		// Choose a random direction to build the path
		for (dir in 0...FlxRandom.shuffleArray<Int>([FlxObject.UP, FlxObject.DOWN, FlxObject.LEFT, FlxObject.RIGHT], 12))
		{
			if (node.paths.get(dir) == null)
			{
				path.nodes = makePathFrom(node, dir);
				break;
			)
		}
		
		node.paths.put(dir, path);
		return path;
	}
	
	function makePathFrom(from : FlxPoint, direction : Int) : Array<FlxPoint>
	{
		var points : Array<FlxPoint>();
	
		var lastPoint : FlxPoint = from;
		for (i in 0...FlxRandom.intRanged(1, 3))
		{
			var point : FlxPoint = new FlxPoint();
			
			switch (direction)
			{
				case FlxObject.LEFT:
					point.x -= FlxRandom.intRanged(16, 32);
				case FlxObject.RIGHT:
					point.x += FlxRandom.intRanged(16, 32);
				case FlxObject.UP:
					point.y -= FlxRandom.intRanged(16, 32);
				case FlxObject.DOWN:
					point.y += FlxRandom.intRanged(16, 32);
			}
			
			points.add(point);
			lastPoint = point;
			direction = FlxRandom.getObject<Int>([FlxObject.UP, FlxObject.DOWN, FlxObject.LEFT, FlxObject.RIGHT]);
	}
}