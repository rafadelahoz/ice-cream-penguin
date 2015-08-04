package;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxTypedGroup;

using flixel.util.FlxSpriteUtil;

class GUI extends FlxTypedGroup<FlxSprite>
{
	var statusGfx : FlxSprite;
	var temperatureBar : FlxSprite;
	var temperatureCursor : FlxSprite;
	var temperatureGfx : FlxSprite;

	var text : FlxText;

	public function new()
	{
		super();
		
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
		
		text = new FlxText(32, 27, 48, "");
		add(text);

		// Scrollfactor.set()
		forEach(function(spr : FlxSprite) {
			spr.scrollFactor.set();
		});
	}
	
	public function updateGUI(icecream : Icecream, world : PlayState) : Void
	{
		// Update temperature
		var ice : Float = icecream.ice;
		var hp : Int = Std.int(ice / 10 * 4);
		
		temperatureBar.fill(0xFFBE3241);
		temperatureBar.drawRect(0, 0, hp + 1, 8, 0xFF3EA5F2);

		temperatureCursor.x = temperatureBar.x + hp;

		statusGfx.animation.play("status", true, Std.int(10 - ice/10));

		if (ice < 30)
			temperatureGfx.animation.play("panic");
		else
			temperatureGfx.animation.play("idle");

		// text.text = "Ice: " + ice + "[" + Std.int(10 - ice/10) + "]";
	}
}