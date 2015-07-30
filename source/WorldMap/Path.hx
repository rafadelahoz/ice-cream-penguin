package;

import flixel.util.FlxPoint;

class Path
{
	public var nodes : Array<FlxPoint>;
	public var pointA : Node;
	public var pointB : Node;
	public var directionA : Int;
	public var directionB : Int;
	
	public function new(?Nodes : Array<FlxPoint>, ?From : Node, ?To : Node, ?FromDirection : Int, ?ToDirection : Int)
	{
		if (Nodes == null)
			Nodes = new Array<FlxPoint>();
		nodes = Nodes;
		
		pointA = From;
		pointB = To;
		directionA = FromDirection;
		directionB = ToDirection;
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
		
		// 'K go!
		return inverse;
	}
}