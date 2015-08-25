package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxRect;
import flixel.util.FlxPoint;
import flixel.util.FlxColorUtil;

using flixel.util.FlxSpriteUtil;

class GUI extends FlxTypedGroup<FlxSprite>
{
	var statusGfxOffsetX : Int = 8;
	var temperatureBarOffsetX : Int = 31;
	var temperatureGfxOffsetX : Int = 24;

	var position : Int;
	
	var statusGfx : FlxSprite;
	var temperatureBar : FlxSprite;
	var temperatureCursor : FlxSprite;
	var temperatureGfx : FlxSprite;
	var boundary : FlxRect;
	
	var text : FlxText;

	public function new()
	{
		super();
		
		position = FlxObject.LEFT;
		
		// Add elements
		// Ice cream status gfx
		statusGfx = new FlxSprite(8, 8);
		statusGfx.loadGraphic("assets/images/hud_icestate.png", true, 24, 24);
		statusGfx.animation.add("status", [0, 0, 0, 0, 1, 2, 3, 4, 5, 6], 0, false);
		statusGfx.animation.play("status");
		add(statusGfx);
		
		// Temperature Bar
		temperatureBar = new FlxSprite(31, 16);
		temperatureBar.makeGraphic(44, 8, 0x00000000);
		add(temperatureBar);

		temperatureCursor = new FlxSprite(31, 16);
		temperatureCursor.loadGraphic("assets/images/hud_temperature-cursor.png");
		add(temperatureCursor);
		
		// Temperature Gfx
		temperatureGfx = new FlxSprite(24, 8);
		temperatureGfx.loadGraphic("assets/images/hud_temperature-overlay.png", true, 72, 24);
		temperatureGfx.animation.add("idle", [0]);
		temperatureGfx.animation.add("panic", [1, 0], 4, true);
		add(temperatureGfx);
		
		// Setup boundary
		boundary = new FlxRect(0, 0, 24 + 72 + 8, 8 + 24 + 8);
		
		text = new FlxText(32, 27, 48, "");
		add(text);
		
		updateElementsPosition();
		
		// Scrollfactor.set()
		forEach(function(spr : FlxSprite) {
			spr.scrollFactor.set();
		});
	}
	
	public function updateGUI(icecream : Icecream, world : PlayState) : Void
	{
		// Update the boundary position
		updateBoundaryPosition();
	
		// Handle the GUI position
		handlePosition(world);
	
		updateTemperature(icecream);

		updateHumidity(icecream);
	}
	
	private function updateTemperature(icecream : Icecream)
	{
		// Update temperature
		var ice : Float = icecream.ice;
		var hp : Int = Std.int(ice / 10 * 4);
		
		temperatureBar.fill(0xFFBE3241);
		temperatureBar.drawRect(0, 0, hp + 1, 8, 0xFF3EA5F2);

		temperatureCursor.x = temperatureBar.x + hp;

		var frameIndex : Int = Std.int(10 - ice/10);
		if (frameIndex < 0 || frameIndex > 9)
			frameIndex = 9;
		statusGfx.animation.play("status", true, frameIndex);
		
		if (ice < 30)
			temperatureGfx.animation.play("panic");
		else
			temperatureGfx.animation.play("idle");
	
		// Pause the awfull termomether animation on death or win
		temperatureGfx.animation.paused = PlayFlowManager.get().paused;
		
		// text.text = "Ice: " + ice + "[" + Std.int(10 - ice/10) + "]";
	}
	
	private function updateHumidity(icecream : Icecream)
	{
		var dry : Float = icecream.dry;
		var hp : Float = 1 - dry / 100.0;
		
		// Lerp from white towards blue-ish when getting wet (hm...)
		var color : Int = FlxColorUtil.makeFromARGB(1, 255 - Std.int((255-62)*hp), 255 - Std.int((255-165)*hp), 255 - Std.int((255 - 242)*hp));
		
		// Tint the hud
		statusGfx.color = color;
		// temperatureGfx.color = color;
		
		// text.text = "Dry: " + hp + "[from:" + dry + "]";
	}
	
	private function handlePosition(world : PlayState)
	{
		var penguin : Penguin = world.penguin;
		var pengPos : FlxPoint = penguin.getMidpoint();
		
		if (boundary.containsFlxPoint(pengPos))
		{
			switchPosition();			
			updateElementsPosition();
		}
	}
	
	public function switchPosition() : Void
	{
		if (position == FlxObject.LEFT)
			position = FlxObject.RIGHT;
		else
			position = FlxObject.LEFT;
	}
	
	public function updateBoundaryPosition() : Void
	{
		if (position == FlxObject.RIGHT)
			boundary.x = Std.int(FlxG.camera.scroll.x + FlxG.camera.width - boundary.width)
		else
			boundary.x = FlxG.camera.scroll.x;
		
		boundary.y = FlxG.camera.scroll.y;
	}
	
	public function updateElementsPosition() : Void
	{
		var baseX : Int = 0;
		if (position == FlxObject.RIGHT)
			baseX = Std.int(FlxG.camera.width - boundary.width);
			
		statusGfx.x = baseX + statusGfxOffsetX;
		temperatureBar.x = baseX + temperatureBarOffsetX;
		temperatureGfx.x = baseX + temperatureGfxOffsetX;
		
		updateBoundaryPosition();
	}
}