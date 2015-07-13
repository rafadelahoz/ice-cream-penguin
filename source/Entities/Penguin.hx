package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxTimer;
import flixel.util.FlxPoint;
import flixel.ui.FlxVirtualPad;
import flixel.ui.FlxButton;

class Penguin extends FlxSprite
{
	public static var virtualPad : FlxVirtualPad;
	var previousPadState : Map<Int, Bool>;
	var currentPadState : Map<Int, Bool>;

	var world : PlayState;

	var timer : FlxTimer;

	var icecream : Icecream;

	var gravity : Int = GameConstants.Gravity;
	var hspeed : Int = 90;
	var jumpSpeed : Int = 250;

	var onWater : Bool;
	var waterBody : FlxObject;
	var onAir : Bool;

	var playerJumped : Bool;

	var stunned : Bool;

	public static var CarrySide : Int = 0;
	public static var CarryTop : Int = 1;
	var carryPos : Int;
	var carryAnim = ["side", "top"];

	var icecreamOffset : Map <Int, Map<Int, FlxPoint>>;

	public function new(X:Int, Y:Int, parent:PlayState)
	{
		super(X, Y);
		
		world = parent;
		
		setupOffset();

		// Setup graphics
		loadGraphic("assets/images/penguin.png", true, 40, 32);
		centerOrigin();
		offset.set(12, 13);
		setSize(16, 19);

		animation.add("idle", [0]);
		animation.add("walk", [1, 2, 3, 2], 12, true);
		animation.add("jump", [4]);
		animation.add("fall", [5]);
		animation.add("hurt", [6, 7], 6, true);

		// Ice cream & carrying setup
		setupIcecream();

		carryPos = CarrySide;

		// State variables init
		onWater = false;
		onAir = false;

		acceleration.x = 0;
		acceleration.y = gravity;

		timer = null;

		setupVirtualPad();
	}

	override public function update() : Void
	{
		handlePadState();

		// Death proof
		if (y > FlxG.camera.bounds.bottom)
		{
			y = FlxG.camera.bounds.bottom;
			velocity.y = -jumpSpeed * 2;
		}

		if (!stunned) {
			// Horizontal movement
			if (FlxG.keys.anyPressed(["LEFT"]) || checkButton(Left))
			{
				facing = FlxObject.LEFT;
				velocity.x = -hspeed;
				animation.play("walk"); 
			}
			else if (FlxG.keys.anyPressed(["RIGHT"]) || checkButton(Right))
			{
				facing = FlxObject.RIGHT;
				velocity.x = hspeed;
				animation.play("walk"); 
			}
			else 
			{
				velocity.x = 0;
				animation.play("idle"); 
			}
		}
		else {
			animation.play("hurt");
		}

		if (!onWater) 
		{
			acceleration.y = gravity;

			if (!stunned)
			{
				// Vertical movement
				if (velocity.y == 0 && isTouching(FlxObject.DOWN)) 
				{
					jump();
				} 
				else
				{
					if (velocity.y < 0 && (playerJumped && (!FlxG.keys.anyPressed(["A", "Z"]) || checkButton(A))))
					{
						velocity.y /= 2;
						playerJumped = false;
					}

					if (velocity.y < 0)
						animation.play("jump");
					else
						animation.play("fall");
				}
			}
		}
		else // if (onWater) 
		{
			if (stunned)
				stunned = false;

			var surfaceY = waterBody.y;

			if (y + height > surfaceY + height * 2)
			{
				acceleration.y = -gravity * 0.6;
			} 
			else 
			{
				if (y + height/2.5 > surfaceY) {
					acceleration.y = -gravity * 0.15;
				} else {
					acceleration.y = gravity * 0.15;
				}

				var maxWaterVSpeed : Float = 20;
				if (Math.abs(velocity.y) > maxWaterVSpeed)
					velocity.y *= 0.75;

				jump();
			}

			

			animation.play("jump");
		}

		// Carried object control
		if (!stunned)
		{
			if (FlxG.keys.anyJustPressed(["S", "X"]) || justPressed(B))
				carryPos = (carryPos + 1) % 2; 
		}

		// Control flipping
		flipX = (facing == FlxObject.LEFT);

		// Actually update
		super.update();

		// Handle icecream
		if (icecream != null)
		{
			var offsetMap : Map<Int, FlxPoint> = icecreamOffset.get(carryPos);
			var aoffset : FlxPoint = offsetMap.get(facing);
			icecream.x = x + aoffset.x;
			icecream.y = y + aoffset.y;

			icecream.offset.x = offset.x + aoffset.x;
			icecream.offset.y = offset.y + aoffset.y;

			icecream.flipX = flipX;		

			icecream.animation.play(animation.name + "-" + carryAnim[carryPos], false, animation.frameIndex);
			
		}

		// Reset state
		onWater = false;
	}

	override public function draw() : Void
	{
		super.draw();

		icecream.render(animation.frameIndex, carryPos);
	}

	override public function destroy() : Void
	{

	}

	public function hit(duration : Float = 0.2, ?direction : Int = FlxObject.NONE, ?force : Bool = false) 
	{
		if (stunned && !force)
			return;

		if (direction == FlxObject.NONE)
			if (facing == FlxObject.RIGHT)
				direction = FlxObject.LEFT;
			else
				direction = FlxObject.RIGHT;

		if (direction == FlxObject.RIGHT)
		{
			facing = FlxObject.LEFT;
			velocity.x = hspeed * 0.25;
		}
		else
		{
			velocity.x = -hspeed * 0.25;
			facing = FlxObject.RIGHT;
		}

		velocity.y = -jumpSpeed * 0.5;

		stunned = true;

		timer = new FlxTimer(duration, onTimer);
	}

	public function bounce()
	{
		velocity.y = -jumpSpeed * 0.7;
	}

	public function jump(?force : Bool = false) : Void
	{
		if (force || FlxG.keys.anyJustPressed(["A", "Z"]) || justPressed(A))
		{
			velocity.y = -jumpSpeed;
			playerJumped = true;
		}
	}

	public function onCollisionWithEnemy(enemy : Enemy) : Void
	{
		if (enemy.type == "Runner")
		{
			if (getMidpoint().y < enemy.y)
				velocity.y = -jumpSpeed * 0.5;
			else 
			{
				if (getMidpoint().x > enemy.getMidpoint().x)
			 		hit(0.5, FlxObject.RIGHT);
			 	else
			 		hit(0.5, FlxObject.LEFT);
			}
		}
	}

	public function onCollisionWithHazard(hazard : Hazard) : Void
	{

	}

	public function onTimer(theTimer : FlxTimer) : Void
	{
		stunned = false;

		timer = null;
	}

	public function onEnterWater(waterBlock : FlxObject) : Void
	{
		waterBody = waterBlock;
		onWater = true;
	}

	public function getIcecream() : Icecream
	{
		return icecream;
	}

	public function getPosition(?point : FlxPoint) : FlxPoint
	{
		return getMidpoint(point);
	}

	private function setupIcecream() : Void
	{
		icecream = new Icecream(x, y);
	}

	private function setupOffset() : Void
	{
		icecreamOffset = new Map<Int, Map<Int, FlxPoint>>();
		var sideOffset : Map<Int, FlxPoint> = new Map<Int, FlxPoint>();
		sideOffset.set(FlxObject.LEFT, new FlxPoint(-10, 0));
		sideOffset.set(FlxObject.RIGHT, new FlxPoint(14, 0));
		icecreamOffset.set(0, sideOffset);

		var topOffset : Map<Int, FlxPoint> = new Map<Int, FlxPoint>();
		topOffset.set(FlxObject.LEFT, new FlxPoint(2, -12));
		topOffset.set(FlxObject.RIGHT, new FlxPoint(2, -12));
		icecreamOffset.set(1, topOffset);
	}

	private function setupVirtualPad() : Void
	{	
		virtualPad = new FlxVirtualPad(LEFT_RIGHT, A_B);
		virtualPad.alpha = 0.65;

		setupVPButton(virtualPad.buttonRight);
		setupVPButton(virtualPad.buttonLeft);
		virtualPad.buttonLeft.x += 10;
		setupVPButton(virtualPad.buttonA);
		setupVPButton(virtualPad.buttonB);
		virtualPad.buttonB.x += 10;
	}

	private function setupVPButton(button : FlxSprite) : Void
	{
		button.scale.x = 0.5;
		button.scale.y = 0.5;
		button.width *= 0.5;
		button.height *= 0.5;
		button.updateHitbox();
		button.y += 17;
	}

	function checkButton(button : Int) : Bool
	{
		return currentPadState.get(button);
	}

	function justPressed(button : Int) : Bool
	{
		return currentPadState.get(button) && !previousPadState.get(button);
	}

	function justReleased(button : Int) : Bool
	{
		return !currentPadState.get(button) && previousPadState.get(button);
	}

	private function initPadState() : Void
	{
		currentPadState = new Map<Int, Bool>();
		currentPadState.set(Left, false);
		currentPadState.set(Right, false);
		currentPadState.set(A, false);
		currentPadState.set(B, false);

		previousPadState = new Map<Int, Bool>();
		previousPadState.set(Left, false);
		previousPadState.set(Right, false);
		previousPadState.set(A, false);
		previousPadState.set(B, false);
	}

	private function handlePadState() : Void
	{
		previousPadState = currentPadState;
		currentPadState = new Map<Int, Bool>();
		currentPadState.set(Left, virtualPad.buttonLeft.status == FlxButton.PRESSED);
		currentPadState.set(Right, virtualPad.buttonRight.status == FlxButton.PRESSED);
		currentPadState.set(A, virtualPad.buttonA.status == FlxButton.PRESSED);
		currentPadState.set(B, virtualPad.buttonB.status == FlxButton.PRESSED);
	}

	private static var Left : Int = 0;
	private static var Right : Int = 1;
	private static var A : Int = 2;
	private static var B : Int = 3;
}