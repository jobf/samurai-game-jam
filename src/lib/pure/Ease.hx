package lib.pure;

import lib.pure.Transformation;

/**
	Ease or "tween" between two values
**/
class Ease
{
	var initial_value: Float;
	var target_value: Float;
	var duration: Float;
	var transformation: Transformation;
	var time: Float;

	public function new(initial_value: Float, target_value: Float, duration: Float, transformation: Transformation)
	{
		configure(initial_value, target_value, duration, transformation);
	}

	/**
		configures the easing
		@param transformation is optional, when null, the previous Transformation is not changed
	**/
	public function configure(initial_value: Float, target_value: Float, duration: Float, transformation: Transformation = null)
	{
		this.initial_value = initial_value;
		this.target_value = target_value;
		this.duration = duration;

		if (transformation == null && this.transformation != null)
		{
			transformation = this.transformation;
		}

		this.transformation = transformation == null ? linear : transformation;
		this.time = 0;
	}

	/** 
		advance internal time and return interpolated value
	**/
	public function step(delta: Float): Float
	{
		var value_now = value_at_time(time);
		time += delta;
		return value_now;
	}

	/**
		return interpolated value for the absolute time
	**/
	public inline function value_at_time(absolute_time: Float)
	{
		return absolute_time > duration ? target_value : interpolate(absolute_time);
	}

	inline function interpolate(time: Float)
	{
		var t = (0 * (1 - time) + 1 * time) /= duration;
		var a: Float = transformation(t);
		return target_value * a + initial_value * (1 - a);
	}

	/**
		determines if the easing is finished
	**/
	public function is_at_end(): Bool
	{
		return time > duration || time == 0;
	}

	/**
		reset time to zero so the next value from step() will be at the start of the curve
	**/
	public function reset_time()
	{
		time = 0;
	}
}
