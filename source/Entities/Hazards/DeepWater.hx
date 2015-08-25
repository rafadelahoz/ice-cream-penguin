package;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.tile.FlxTileblock;

class DeepWater extends Hazard
{
	var tideTween : FlxTween;
	var surface : FlxTileblock;
	
	public function new(X : Int, Y : Int, Width : Int, Height : Int, World : PlayState)
	{
		super(X, Y, Hazard.HazardType.Water, World);
		
		makeGraphic(Width, Height, 0xFF010877);
		setSize(Width, Height);
		centerOrigin();
		
		surface = new FlxTileblock(X, Y, Width, 8);
		surface.loadTiles("assets/images/water-surface.png", 8, 8);
		
		tideTween = FlxTween.tween(this, {y: y + 3}, 1+Math.random(), { ease: FlxEase.quadInOut, type: FlxTween.PINGPONG });
	}
	
	override public function update() : Void
	{
		if (PlayFlowManager.get().paused)
		{
			tideTween.active = false;
			return;
		}
		else
		{
			tideTween.active = true;
		}
	
		super.update();
		
		surface.y = y;
		surface.update();
	}
	
	override public function draw() : Void
	{
		super.draw();
		surface.draw();
	}
}