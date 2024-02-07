package lib.pure;

typedef Transformation = (t: Float) -> Float;

// linear
// ------
var linear: Transformation = t -> t;

// quadratic
// ---------
var smooth_start_2: Transformation = t -> t * t;
var smooth_stop_2: Transformation = t -> -(t * (t - 2));
var smooth_start_stop_2: Transformation = t -> t < 0.5 ? 2 * t * t : (-2 * t * t) + (4 * t) - 1;

// cubic
// -----
var smooth_start_3: Transformation = t -> t * t * t;
var smooth_stop_3: Transformation = t -> (t - 1) * (t - 1) * (t - 1) + 1;

var smooth_start_stop_3: Transformation = t ->
{
	if (t < 0.5)
	{
		return 4 * t * t * t;
	}
	else
	{
		var p = 2 * t - 2;
		return 0.5 * p * p * p + 1;
	};
}

// quartic
// -------
var smooth_start_4: Transformation = t -> t * t * t * t;
var smooth_stop_4: Transformation = t -> (t - 1) * (t - 1) * (t - 1) * (1 - t) + 1;

var smooth_start_stop_4: Transformation = t ->
{
	if (t < 0.5)
	{
		return 8 * t * t * t * t;
	}
	var p = t - 1;
	return -8 * p * p * p * p + 1;
}

// quintic
// ------
var smooth_start_5: Transformation = t -> t * t * t * t * t;
var smooth_stop_5: Transformation = t -> (t - 1) * (t - 1) * (t - 1) * (t - 1) * (t - 1) + 1;

var smooth_start_stop_5: Transformation = t ->
{
	if (t < 0.5)
	{
		return 16 * t * t * t * t * t;
	}
	var p = (2 * t) - 2;
	return 0.5 * p * p * p * p * p + 1;
}

// sine
// ----
var sine_start: Transformation = t -> Math.sin((t - 1) * Math.PI / 2) + 1;
var sine_stop: Transformation = t -> Math.sin(t * Math.PI / 2);
var sine_start_stop: Transformation = t -> 0.5 * (1 - Math.cos(t * Math.PI));

// circular
// --------
var circular_start: Transformation = t -> 1 - Math.sqrt(1 - (t * t));
var circular_stop: Transformation = t -> Math.sqrt((2 - t) * t);

var circular_start_stop: Transformation = t ->
{
	if (t < 0.5)
	{
		return 0.5 * (1 - Math.sqrt(1 - 4 * (t * t)));
	}
	return 0.5 * (Math.sqrt(-((2 * t) - 3) * ((2 * t) - 1)) + 1);
};

// exponential
// -----------
var exponential_start: Transformation = t ->
{
	if (t == 0)
	{
		return t;
	}
	return Math.pow(2, 10 * (t - 1));
}

var exponential_stop: Transformation = t ->
{
	if (t == 1)
	{
		return t;
	}
	return 1 - Math.pow(2, -10 * t);
}

var exponential_start_stop: Transformation = t ->
{
	if (t == 0 || t == 1)
	{
		return t;
	}
	if (t < 0.5)
	{
		return 0.5 * Math.pow(2, (20 * t) - 10);
	}
	return -0.5 * Math.pow(2, (-20 * t) + 10) + 1;
}

// elastic
// -------
var elastic_start: Transformation = t -> Math.sin(13 * Math.PI / 2 * t) * Math.pow(2, 10 * (t - 1));
var elastic_stop: Transformation = t -> Math.sin(-13 * Math.PI / 2 * (t + 1)) * Math.pow(2, -10 * t) + 1;

var elastic_start_stop: Transformation = t ->
{
	if (t < 0.5)
	{
		return 0.5 * Math.sin(13 * Math.PI / 2 * (2 * t)) * Math.pow(2, 10 * ((2 * t) - 1));
	}
	return 0.5 * (Math.sin(-13 * Math.PI / 2 * ((2 * t - 1) + 1)) * Math.pow(2, -10 * (2 * t - 1)) + 2);
};

// back
// ----
var back_start: Transformation = t -> t * t * t - t * Math.sin(t * Math.PI);

var back_stop: Transformation = t ->
{
	var p = 1 - t;
	return 1 - (p * p * p - p * Math.sin(p * Math.PI));
};

var back_start_stop: Transformation = t ->
{
	if (t < 0.5)
	{
		var p = 2 * t;
		return 0.5 * (p * p * p - p * Math.sin(p * Math.PI));
	}
	var p = 1 - (2 * t - 1);
	return 0.5 * (1 - (p * p * p - p * Math.sin(p * Math.PI))) + 0.5;
};

// bounce
// ------
var bounce_start: Transformation = t -> 1 - bounce_stop(1 - t);

var bounce_stop: Transformation = t ->
{
	if (t < 4 / 11)
	{
		return 121 * t * t / 16;
	}
	if (t < 8 / 11)
	{
		return (363 / 40.0 * t * t) - (99 / 10.0 * t) + 17 / 5.0;
	}
	if (t < 9 / 10)
	{
		return (4356 / 361.0 * t * t) - (35442 / 1805.0 * t) + 16061 / 1805.0;
	}
	return (54 / 5.0 * t * t) - (513 / 25.0 * t) + 268 / 25.0;
};

var bounce_start_stop: Transformation = t ->
{
	if (t < 0.5)
	{
		return 0.5 * bounce_start(t * 2);
	}
	return 0.5 * bounce_stop(t * 2 - 1) + 0.5;
};

var flip: Transformation = t -> 1 - t;

function mix(a: Transformation, b: Transformation, weight_b: Float, t: Float): Float
{
	return ((1 - weight_b) * a(t)) + ((weight_b) * b(t));
}

function crossfade(a: Transformation, b: Transformation, t: Float): Float
{
	return ((1 - t) * a(t)) + ((t) * b(t));
}

function scale(a: Transformation, t: Float): Float
{
	return a(t) * t;
}

function reverse_scale(a: Transformation, t: Float): Float
{
	return a(t) * (1 - t);
}

function recurse(t: Float, order: Int): Float
{
	var v = t;
	for (n in 0...order)
	{
		v = recurse(t, n);
	};
	return v;
}

@:publicFields
class SstepN
{
	static inline function smooth_step_n(t: Float, n: Int): Float
	{
		return crossfade(
			t -> recurse(smooth_start_2(t), n),
			t -> recurse(smooth_stop_2(t), n),
			t
		);
	}
}

var mixed_start3_stop5: Transformation = t -> mix(smooth_start_2, smooth_stop_5, 0.5, t);
var smooth_start_2_point_2: Transformation = t -> mix(smooth_start_2, smooth_start_3, 0.2, t);
var smooth_start_2_cross_smooth_stop_2: Transformation = t -> crossfade(smooth_start_2, smooth_stop_3, t);
var smooth_step_2: Transformation = t -> crossfade(smooth_start_2, smooth_stop_2, t);
var smooth_step_3: Transformation = t -> crossfade(smooth_start_3, smooth_stop_3, t);
var smooth_step_3_B: Transformation = t -> SstepN.smooth_step_n(t, 3);
var smooth_step_4: Transformation = t -> crossfade(smooth_start_4, smooth_stop_4, t);
var smooth_step_5: Transformation = t -> crossfade(smooth_start_5, smooth_stop_5, t);
var arch_2: Transformation = t -> scale(flip, t);
