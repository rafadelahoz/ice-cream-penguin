package;

import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;

using flixel.util.FlxSpriteUtil;

class GUI extends FlxTypedGroup<FlxSprite>
{
	var statusGfx : FlxSprite;
	var temperatureBar : FlxSprite;
	var temperatureGfx : FlxSprite;

	public function new()
	{
		super();
		
		// Add elements
		// Ice cream status gfx
		statusGfx = new FlxSprite(8, 8);
		statusGfx.makeGraphic(24, 24, 0x00000000);
		statusGfx.drawCircle(12, 12, 12);
		add(statusGfx);
		
		// Temperature Bar
		temperatureBar = new FlxSprite(32, 12);
		temperatureBar.makeGraphic(80, 16, 0x00000000);
		add(temperatureBar);
		
		// Temperature Gfx
		temperatureGfx = new FlxSprite(32, 12);
		temperatureGfx.makeGraphic(80, 16, 0x00000000);
		temperatureGfx.drawRect(1, 1, 77, 13, 0x00000000, { thickness: 3, color: 0xFFFFFFFF });
		temperatureGfx.drawRect(1, 1, 77, 13, 0x00000000, { thickness: 1, color: 0xFF000000 });
		add(temperatureGfx);
		
		// Scrollfactor.set()
		forEach(function(spr : FlxSprite) {
			spr.scrollFactor.set();
		});
	}
	
	public function updateGUI(icecream : Icecream, world : PlayState) : Void
	{
		// Update temperature
		var ice : Float = icecream.ice;
		var hp : Int = Std.int(ice / 10 * 8);
		
		temperatureBar.fill(0xFFBE3241);
		temperatureBar.drawRect(0, 0, hp, 16, 0xFF3EA5F2);
		
		temperatureGfx.drawRect(1, 1, 77, 13, 0x00000000, { thickness: 3, color: 0xFFFFFFFF });
		temperatureGfx.drawRect(1, 1, 77, 13, 0x00000000, { thickness: 1, color: 0xFF000000 });
	}
}