package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.tile.FlxTileblock;
import flixel.util.FlxGradient;
import flixel.util.FlxRandom;
import flixel.util.FlxTimer;

class LavaPool extends Hazard
{
	var waitTime : Float = 1.6;
	var waitDelta : Float = 0.3;

	var tideTween : FlxTween;
	var surface : FlxTileblock;
	var gradient : FlxSprite;
	
	var timer : FlxTimer;
	var effects : FlxTypedGroup<LavaEffect>;
	
	public function new(X : Int, Y : Int, Width : Int, Height : Int, World : PlayState)
	{
		super(X, Y, Hazard.HazardType.Fire, World);
		
		makeGraphic(Width, Height, 0xFFFF294F);
		setSize(Width, Height);
		centerOrigin();
		
		surface = new FlxTileblock(X, Y, Width, 8);
		surface.loadTiles("assets/images/lava-surface.png", 8, 8);
		
		// Temporal gradient thing
		gradient = FlxGradient.createGradientFlxSprite(Std.int(width), Std.int(height * 2), [0x00000000, 0x20FFC200, 0xDFFF294F], 8);
		gradient.x = X;
		gradient.y = y - height;
		
		tideTween = FlxTween.tween(this, {y: y + 3}, 1+Math.random(), { ease: FlxEase.quadInOut, type: FlxTween.PINGPONG });
		
		setupEffects();
	}
	
	override public function destroy() : Void
	{
		effects.destroy();
		effects = null;

		timer.destroy();
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
	
		effects.forEachAlive(function (effect : LavaEffect) {
			effect.update();
		});
	
		super.update();
		
		surface.y = y;
		surface.update();
		
		// Do not move the gradient with the lava!
		// (else it looks like a hard-coded block)
		/*gradient.x = x;
		gradient.y = y - height;*/
		gradient.update();
	}
	
	override public function draw() : Void
	{
		super.draw();
		surface.draw();
		
		effects.forEachAlive(function (effect : LavaEffect) {
			effect.draw();
		});
		
		gradient.draw();
	}
	
	override public function onCollisionWithPlayer(player : Penguin) : Bool
	{
		player.jumpCry();
		return true;
	}
	
	override public function onCollisionWithIcecream(icecream : Icecream)
	{
		// Melt
		icecream.makeHotter(1000);
	}
	
	function setupEffects()
	{
		effects = new FlxTypedGroup<LavaEffect>(50);
		for (i in 0...50)
		{
			var effect : LavaEffect = new LavaEffect(x, y);
			effect.kill();
			effects.add(effect);
		}
		
		timer = new FlxTimer(getWaitTime(), spawnEffect);
	}
	
	function spawnEffect(_timer : FlxTimer) : Void
	{
		var effect : LavaEffect = effects.recycle(LavaEffect);
		var xx : Int = FlxRandom.intRanged(Std.int(x), Std.int(x + width));
		var yy : Int = FlxRandom.intRanged(Std.int(y), Std.int(y + height / 2));
		
		effect.init(xx, yy);
		
		timer.reset(getWaitTime());
	}
	
	function getWaitTime()
	{
		var waitLimit : Float = waitTime + waitTime * waitDelta;
		return FlxRandom.floatRanged(-waitLimit, waitLimit);
	}
}

class LavaEffect extends FlxSprite
{
	public function new(X : Float, Y : Float)
	{
		super(X, Y);
		
		loadGraphic("assets/images/lava-effects.png", true, 9, 9);
	}
	
	public function init(X : Float, Y : Float)
	{
		x = X;
		y = Y;
	
		animation.destroyAnimations();
	
		// Choose a random effect
		if (FlxRandom.chanceRoll(60))
			animation.add("idle", [0, 1, 2, 3, 7], FlxRandom.intRanged(4, 9), false);
		else
			animation.add("idle", [4, 5, 6, 7, 7], FlxRandom.intRanged(4, 9), false);
			
		animation.play("idle");
	}
	
	override public function update()
	{
		if (animation.finished && alive)
		{
			kill();
		}
		
		y -= FlxRandom.floatRanged(0, 0.5);
		
		super.update();
	}
}