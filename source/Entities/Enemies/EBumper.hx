package;

class EBumper extends Enemy
{
	public function new(X : Float = 0, Y : Float = 0, World : PlayState = null)
	{

		super(X, Y, World);
		makeGraphic(24, 24, 0xFFAA3333);

		brain = new StateMachine(idle);
	}

	public function idle() : Void
	{
		acceleration.y = 300;
		// velocity
	}

	public function surprise() : Void
	{

	}

	public function chase() : Void
	{

	}

	public function rest() : Void
	{

	}
}