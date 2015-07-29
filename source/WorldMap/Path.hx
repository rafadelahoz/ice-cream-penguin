package map;

import flixel.util.FlxPoint;

class Path
{
	public var nodes : Array<FlxPoint>;
	public var pointA : Node;
	public var pointB : Node;
	
	public function new(?Nodes : Array<FlxPoint>, ?From : Node, ?To : Node)
	{
		if (Nodes == null)
			Nodes = new Array<FlxPoint>();
		nodes = Nodes;
		
		pointA = From;
		pointB = To;
	}
	
	
}