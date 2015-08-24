package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxTimer;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;

class Penguin extends Entity
{
	var timer : FlxTimer;

	var icecream : Icecream;

	var gravity : Int = GameConstants.Gravity;
	
	var hspeed : Int = 70;
	var maxHspeed : Int = 85;
	var jumpHspeed : Float = 3;
	var jumpSpeed : Int = 195;
	
	var bounceJumpFactor : Float = 0.95;
	var bounceFactor : Float = 0.4;
	
	var stunJumpFactor : Float = 0.4;
	var stunHSpeedFactor : Float = 0.25;
	
	var waterSpeedFactor : Float = 0.9;
	var waterMaxVSpeed : Float = 20;
	var waterGravityFactor : Float = 0.6;
	var waterSurfaceGravityFactor : Float = 0.15;
	var waterFallSpeedReduction : Float = 0.75;
	
	var hazardCollisionStunTime : Float = 0.75;
	var enemyCollisionStunTime	: Float = 0.75;
	
	var onWater : Bool;
	var waterBody : Hazard;
	var onAir : Bool;

	var playerJumped : Bool;
	var turnedOnAir : Bool;

	var stunned : Bool;

	public static var CarrySide : Int = 0;
	public static var CarryTop : Int = 1;
	var carryPos : Int;
	var carryAnim = ["side", "top"];

	var icecreamOffset : Map <Int, Map<Int, FlxPoint>>;

	public function new(X : Int, Y : Int, World : PlayState)
	{
		super(X, Y, World);
		
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
		animation.play("fall");

		// Ice cream & carrying setup
		setupIcecream();

		carryPos = CarrySide;

		// State variables init
		onWater = false;
		onAir = false;

		acceleration.x = 0;
		acceleration.y = gravity;

		timer = null;

		positionCarriedObject();
	}

	override public function update() : Void
	{
		if (frozen)
			return;

		var previouslyOnAir : Bool = onAir;
		onAir = !isTouching(FlxObject.DOWN);

		if (!onAir && previouslyOnAir)
		{
			FlxG.sound.play("land");
		}

		// Death proof
		if (y > FlxG.camera.bounds.bottom)
		{
			y = FlxG.camera.bounds.bottom;
			velocity.y = -jumpSpeed * 2;
		}

		if (onWater) 
		{
			handleWaterBehaviour();
		} 
		else
		{
			if (!stunned) 
			{
				if (!onAir)
				{
					// Horizontal movement
					if (GamePad.checkButton(GamePad.Left))
					{
						facing = FlxObject.LEFT;
						velocity.x = -hspeed;
						animation.play("walk"); 
					}
					else if (GamePad.checkButton(GamePad.Right))
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
				else
				{
					if (GamePad.checkButton(GamePad.Left))
					{
						if (facing == FlxObject.RIGHT && !turnedOnAir)
						{
							facing = FlxObject.LEFT;
							turnedOnAir = true;
						}
						velocity.x -= jumpHspeed;
						velocity.x = Math.max(velocity.x, -maxHspeed);
					}
					else if (GamePad.checkButton(GamePad.Right))
					{
						if (facing == FlxObject.LEFT && !turnedOnAir) 
						{
							facing = FlxObject.RIGHT;
							turnedOnAir = true;
						}
						velocity.x += jumpHspeed;
						velocity.x = Math.min(velocity.x, maxHspeed);
					}
				}
				
				// Vertical movement
				if (velocity.y == 0) 
				{
					jump();
				} 
				else
				{
					if (velocity.y < 0 && (playerJumped && !GamePad.checkButton(GamePad.A)))
					{
						velocity.y /= 2;
						playerJumped = false;
					}

					if (velocity.y < 0)
						animation.play("jump");
					else
						animation.play("fall");
				}
				
				// Carried object control
				handleCarriedObject();
			}
			else // if (stunned)
			{
				animation.play("hurt");
			}
			
			acceleration.y = gravity;
		}

		// Control flipping
		flipX = (facing == FlxObject.LEFT);

		// Actually update
		super.update();

		// Handle icecream
		positionCarriedObject();

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
		super.destroy();
	}
	
	function handleCarriedObject() : Void
	{
		// Switch carry position when the button's pressed
		if (GamePad.justPressed(GamePad.B))
		{
			carryPos = (carryPos + 1) % 2; 

			FlxG.sound.play("switch");
		}
	}

	function positionCarriedObject() : Void
	{
		if (icecream != null)
		{
			var offsetMap : Map<Int, FlxPoint> = icecreamOffset.get(carryPos);
			var aoffset : FlxPoint = offsetMap.get(facing);
			icecream.x = x + aoffset.x + icecream.baseOffset.x;
			icecream.y = y + aoffset.y + icecream.baseOffset.y;

			icecream.offset.x = offset.x + aoffset.x + icecream.baseOffset.x;
			icecream.offset.y = offset.y + aoffset.y + icecream.baseOffset.y;

			icecream.flipX = flipX;		

			icecream.animation.play(animation.name + "-" + carryAnim[carryPos], false, animation.frameIndex);	
		}
	}
	
	public function handleWaterBehaviour() : Void
	{
		if (stunned)
			stunned = false;
	
		// Swimming in dangerous water bodies is not recommended
		if (waterBody.dangerous)
		{
			if (Math.abs(velocity.y) > waterMaxVSpeed)
				velocity.y *= waterFallSpeedReduction;
				
			animation.play("hurt");
			acceleration.y = GameConstants.Gravity * 0.1;
			velocity.x /= 3;
		}
		// Swimming on clean, still waters shall be a really pleasant experience
		else
		{
			// Horizontal movement
			if (GamePad.checkButton(GamePad.Left))
			{
				facing = FlxObject.LEFT;
				velocity.x = -hspeed * waterSpeedFactor;
			}
			else if (GamePad.checkButton(GamePad.Right))
			{
				facing = FlxObject.RIGHT;
				velocity.x = hspeed * waterSpeedFactor;
			}
			else 
			{
				velocity.x = 0;
			}

			// Vertical movement
			var surfaceY = waterBody.y;

			if (y + height > surfaceY + height * 2)
			{
				acceleration.y = -gravity * waterGravityFactor;
			} 
			else 
			{
				if (y + height/2.5 > surfaceY) {
					acceleration.y = -gravity * waterSurfaceGravityFactor;
				} else {
					acceleration.y = gravity * waterSurfaceGravityFactor;
				}
				
				if (Math.abs(velocity.y) > waterMaxVSpeed)
					velocity.y *= waterFallSpeedReduction;

				jump();
			}
			
			// Carried object control
			handleCarriedObject();
			
			// Float animation
			animation.play("jump");
		}
		
		// Check whether the icecream is in danger!
		var rect : FlxRect = new FlxRect(waterBody.x, waterBody.y, waterBody.width, waterBody.height);
		if (icecream.containedIn(rect))
		{
			var ruin : Int = 1;
			if (waterBody.dangerous)
				ruin = 10;
			icecream.water(ruin);
		}
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
			velocity.x = hspeed * stunHSpeedFactor;
		}
		else
		{
			velocity.x = -hspeed * stunHSpeedFactor;
			facing = FlxObject.RIGHT;
		}

		velocity.y = -jumpSpeed * stunJumpFactor;

		stunned = true;

		timer = new FlxTimer(duration, onTimer);
	}

	public function bounce()
	{
		// velocity.y = -jumpSpeed * 0.7;

		if (GamePad.checkButton(GamePad.A))
		{
			velocity.y = -jumpSpeed * bounceJumpFactor;
			playerJumped = true;
			turnedOnAir = false;
		}
		else
			velocity.y = -jumpSpeed * bounceFactor;
	}

	public function jump(?force : Bool = false) : Void
	{
		if (force || GamePad.justPressed(GamePad.A))
		{
			velocity.y = -jumpSpeed;
			playerJumped = true;
			turnedOnAir = false;

			FlxG.sound.play("jump");
		}
	}

	function dangerousHazard(hazardType : Hazard.HazardType) : Bool
	{
		switch (hazardType)
		{
			case Hazard.HazardType.Fire, 
				Hazard.HazardType.Collision,
				Hazard.HazardType.Dirt,
				Hazard.HazardType.Theft:
				return true;
			case Hazard.HazardType.Water, Hazard.HazardType.None:
				return false;
		}
	}

	public function onCollisionWithEnemy(enemy : Enemy) : Void
	{
		if (dangerousHazard(enemy.hazardType) || enemy.type == "Runner" || enemy.type == "Walker")
		{
			// Bounce on the top of the enemy if you are on top
			if (getMidpoint().y < enemy.y)
			{
				bounce();
			}
			// Or just be hit, you sad penguin
			else 
			{
				if (getMidpoint().x > enemy.getMidpoint().x)
			 		hit(enemyCollisionStunTime, FlxObject.RIGHT);
			 	else
			 		hit(enemyCollisionStunTime, FlxObject.LEFT);
			}
		}
	}

	public function onCollisionWithHazard(hazard : Hazard) : Void
	{
		if (hazard.dangerous) 
		{
			/*if (getMidpoint().y < hazard.y)
			{
				bounce();
			}
			else 
			{*/
				hit(hazardCollisionStunTime);
			/*}*/
		}
	}

	public function onTimer(theTimer : FlxTimer) : Void
	{
		stunned = false;

		timer = null;
	}

	public function onEnterWater(waterBlock : Hazard) : Void
	{
		waterBody = waterBlock;
		onWater = true;
	}

	public function onDeath(deathType : String) : Void
	{
		animation.play("hurt");
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
}