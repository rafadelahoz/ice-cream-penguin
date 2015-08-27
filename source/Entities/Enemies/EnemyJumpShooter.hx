package;

import flixel.FlxObject;
import flixel.util.FlxTimer;

class EnemyJumpShooter extends Enemy
{
	var idleTime : Float = 0.0;
	var shootDelay : Float = 3;
	
	var tmp_shootAnimLength : Float = 0.8;
	
	var jumpSpeed : Float = 150;
	var jumpDistance : Float = 100;
	
	public var canShoot : Bool;
	
	var timer : FlxTimer;
	var jumped : Bool;
	
	var shooter : ShooterComponent;
	var shootTimer : FlxTimer;
	var shooting : Bool;

	public function new(X : Float = 0, Y : Float = 0, World : PlayState = null)
	{
		super(X, Y, World);
		
		brain = new StateMachine(null, onStateChange);
		
		shooter = new ShooterComponent();
		timer = new FlxTimer();
		
		canShoot = false;
		shootTimer = new FlxTimer();
	}

	override public function init(?Category : Int, ?Variation : Int) : Void
	{
		super.init(Category, Variation);
		
		hazardType = Hazard.HazardType.Collision;
		
		makeGraphic(18, 18, 0xFFFFFFFF);
		color = 0xFF0F5738;
		
		if (player.getMidpoint().x < getMidpoint().x)
			facing = FlxObject.LEFT;
		else
			facing = FlxObject.RIGHT;
		
		brain.transition(wait, "wait");
		
		if (canShoot)
		{
			shooter.init(world, Hazard.HazardType.Fire, 2, BulletHazard.Behaviour.Straight);
			shootTimer.start(shootDelay, doShoot);
			shooting = false;
		}
	}
	
	override public function destroy() : Void
	{
		timer.destroy();
		shooter.destroy();
	}
	
	override public function freeze() : Void
	{
		super.freeze();
		timer.active = false;
	}

	override public function resume() : Void
	{
		super.resume();
		timer.active = true;
	}
	
	override public function update() : Void
	{
		if (shooting)
			color = 0xFF57380F;
		else
			color = 0xFF0F5738;
	
		super.update();
	}
	
	public function wait()
	{
		// Don't move
		velocity.x = 0;
	
		// Fall
		acceleration.y = GameConstants.Gravity * 0.5;
		
		// Turn to face player
		if (player.getMidpoint().x < getMidpoint().x)
			facing = FlxObject.LEFT;
		else
			facing = FlxObject.RIGHT;

		// Jump when player jumps
		if (shouldJump() && getMidpoint().distanceTo(player.getMidpoint()) < jumpDistance)
		{
			timer.start(idleTime, function(_timer : FlxTimer) {
				brain.transition(jump, "jump");
			});
		}
	}
	
	function shouldJump() : Bool
	{
		return (player.bottom < getMidpoint().y && 
				player.getMidpoint().y > y - height &&
				player.velocity.y < 0);
	}
	
	public function jump()
	{
		// Don't move
		velocity.x = 0;
	
		// Fall
		acceleration.y = GameConstants.Gravity * 0.5;
	
		if (!jumped)
		{
			velocity.y = -jumpSpeed;
			jumped = true;
		}
	
		// When jumping
		if (velocity.y == 0)
		{
			// Turn to face player
			if (player.getMidpoint().x < getMidpoint().x)
				facing = FlxObject.LEFT;
			else
				facing = FlxObject.RIGHT;
		}
		
		if (justTouched(FlxObject.DOWN))
			brain.transition(wait, "wait");
	}
	
	public function prepareShoot() : Void
	{
		shootTimer.start(shootDelay, doShoot);
		shooting = false;
	}
	
	public function doShoot(t : FlxTimer) : Void
	{
		shooting = true;
		shooter.shoot(getMidpoint(), player.getMidpoint());
		shootTimer.start(tmp_shootAnimLength, function(_t:FlxTimer) {
			prepareShoot();
		});
	}
	
	public function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "wait": 
			case "jump":
				jumped = false;
		}
	}
	
	override public function onCollisionWithPlayer(penguin : Penguin)
	{
		if (penguin.getMidpoint().y > getMidpoint().y) 
		{
			// Bounce on penguin
			velocity.y = -jumpSpeed * 0.5;
		}
	
		super.onCollisionWithPlayer(penguin);
	}
}