package lib.pure;

class Loop
{
	var update: Update;
	var step_duration_ms: Float;
	var step_time_accumulator_ms: Float;
	var step_ratio: Float;

	public function new(update: Update, steps_per_second: Float)
	{
		this.update = update;
		step_duration_ms = (Constant.milliseconds_per_second / steps_per_second);
		step_time_accumulator_ms = 0;
		step_ratio = 0;
	}

	/** call this on each render frame **/
	public function frame(elapsed_ms: Float)
	{
		update.start();

		step_time_accumulator_ms += elapsed_ms;

		while (step_time_accumulator_ms > step_duration_ms)
		{
			update.step();
			step_time_accumulator_ms -= step_duration_ms;
		}

		step_ratio = step_time_accumulator_ms / step_duration_ms;

		update.end(step_ratio);
	}
}

@:structInit
@:publicFields
class Update
{
	/** called at start of every frame update **/
	var start: () -> Void = () -> {}

	/** called for every game step at fixed rate, e.g. if frame update is 60 frames per second and fixed step is 30 per second  this will be called approximately every 2nd frame **/
	var step: () -> Void = () -> {}

	/** called at end up update frame, step_ratio is a measurement of progress through the game step between 0 and 1, used for interpolation **/
	var end: (step_ratio: Float) -> Void = (step_ratio) -> {}
}

@:publicFields
class Constant
{
	static var milliseconds_per_second = 1000;
}
