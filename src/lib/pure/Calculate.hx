package lib.pure;

/**
	fast, imprecise linear interpolation
**/
inline function lerp(a: Float, b: Float, t: Float): Float
{
	return a + (b - a) * t;
}

/**
	distance between 2 points 
**/
inline function distance_to_point(x_a: Float, y_a: Float, x_b: Float, y_b: Float): Float
{
	var x_d = x_a - x_b;
	var y_d = y_a - y_b;
	return Math.sqrt(x_d * x_d + y_d * y_d);
}
