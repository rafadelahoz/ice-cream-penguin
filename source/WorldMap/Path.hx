package;

import flixel.util.FlxPoint;

class Path
{
	public var nodes : Array<FlxPoint>;

	public var pointA : Node;
	public var pointB : Node;

	public var directionA : Int;
	public var directionB : Int;
	
	public var lock : String;
	
	public function new(?Nodes : Array<FlxPoint>, ?From : Node, ?To : Node, ?FromDirection : Int, ?ToDirection : Int, ?Lock : String)
	{
		if (Nodes == null)
			Nodes = new Array<FlxPoint>();
		nodes = Nodes;
		
		pointA = From;
		pointB = To;
		
		directionA = FromDirection;
		directionB = ToDirection;
		
		lock = Lock;
	}
	
	public function length() : Float
	{
		var length : Float = 0;
		
		for (i in 0...Std.int(Math.max(0, nodes.length-1)))
		{
			length += nodes[i].distanceTo(nodes[i+1]);
		}
		
		trace("Path length: " + length);
		
		return length;
	}
	
	public function inverse() : Path
	{
		var inverse : Path = new Path();
		// Clone the node list
		inverse.nodes = nodes.copy();
		// And reverse it
		inverse.nodes.reverse();
		
		// Inverse the points and directions
		inverse.pointA = pointB;
		inverse.pointB = pointA;
		inverse.directionA = directionB;
		inverse.directionB = directionA;
		
		// Setup the lock
		inverse.lock = lock;
		
		// 'K go!
		return inverse;
	}
	
	public function isOpen() : Bool
	{
		return GameController.getLock(lock);
	}
}