package lib.pure;

/**
	Allows to repeat a callback every nth time update is called
**/
@:structInit
@:publicFields
class Repeat
{
	/**
		how many times update is called before the action is called
	**/
	var duration: Int;

	/**
		the callback function 
	**/
	var action: Repeat -> Void;

	/**
		keeps track of how many more calls to update are needed before the callback will trigger
	**/
	var remaining: Int = 0;

	/**
		call in e.game update loiop for example
	**/
	function update()
	{
		if (remaining <= 0)
		{
			remaining = duration;
			action(this);
		}
		else
		{
			remaining--;
		}
	}
}
