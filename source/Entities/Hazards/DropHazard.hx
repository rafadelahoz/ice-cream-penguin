package;

class DropHazard extends Hazard 
{
	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, Hazard.HazardType.Fire, World);
	}
}