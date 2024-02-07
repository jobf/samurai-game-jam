package lib.pure;

/**
	Based on deepnight blog posts from 2013
	movemen logic - https://deepnight.net/tutorial/a-simple-platformer-engine-part-1-basics/
	overlap logic - https://deepnight.net/tutorial/a-simple-platformer-engine-part-2-collisions/
**/
class DeepnightMovement
{
	public var position(default, null): Position;
	public var velocity(default, null): Velocity;
	public var size(default, null): Size;
	public var state: MovementState;
	// velocity.delta_y is incremented by this each frame
	public var gravity: Float = 0.05;

	var has_wall_tile_at: (grid_x: Int, grid_y: Int) -> Bool;
	var is_wall_left: Bool;
	var is_wall_right: Bool;
	var is_wall_up: Bool;
	var is_wall_down: Bool;

	public function new(grid_x: Int, grid_y: Int, tile_size: Int, has_wall_tile_at: (grid_x: Int, grid_y: Int) -> Bool)
	{
		var grid_cell_ratio_x = 0.5;
		var grid_cell_ratio_y = 0.5;

		position = {
			grid_x: grid_x,
			grid_y: grid_y,
			grid_cell_ratio_x: grid_cell_ratio_x,
			grid_cell_ratio_y: grid_cell_ratio_y,
			x: Std.int((grid_x + grid_cell_ratio_x) * tile_size),
			y: Std.int((grid_y + grid_cell_ratio_y) * tile_size)
		}

		size = {
			tile_size: tile_size,
			radius: tile_size / 2
		}

		velocity = {}

		state = IDLE;

		this.has_wall_tile_at = has_wall_tile_at;
	}

	public function set_coordinates(x: Float, y: Float, pos: Position, size: Size)
	{
		position.x = x;
		position.y = y;
		position.grid_x = Std.int(x / size.tile_size);
		position.grid_y = Std.int(y / size.tile_size);
		position.grid_cell_ratio_x = (x - position.grid_x * size.tile_size) / size.tile_size;
		position.grid_cell_ratio_y = (y - position.grid_y * size.tile_size) / size.tile_size;
	}

	public function teleport_to_grid(column: Int, row: Int)
	{
		position.grid_x = column;
		position.grid_y = row;
	}

	public function overlaps(other: DeepnightMovement): Bool
	{
		var max_distance = size.radius + other.size.radius;
		var distance_squared = (other.position.x
			- position.x) * (other.position.x - position.x)
			+ (other.position.y - position.y) * (other.position.y - position.y);
		return distance_squared <= max_distance * max_distance;
	}

	public function overlaps_by(other: DeepnightMovement): Float
	{
		var max_distance = size.radius + other.size.radius;
		var distance_squared = (other.position.x
			- position.x) * (other.position.x - position.x)
			+ (other.position.y - position.y) * (other.position.y - position.y);
		return (max_distance * max_distance) - distance_squared;
	}

	public function update()
	{
		update_movement_horizontal();
		update_movement_vertical();
		update_neighbours();
		update_gravity();
		update_collision();
		update_position();
	}

	inline function update_movement_horizontal()
	{
		position.grid_cell_ratio_x += velocity.delta_x;
		velocity.delta_x *= (1.0 - velocity.friction_x);

		// / todo move this higher
		if (Math.abs(velocity.delta_x) < 0.04)
		{
			velocity.delta_x = 0;
		}
	}

	inline function update_movement_vertical()
	{
		position.grid_cell_ratio_y += velocity.delta_y;
		velocity.delta_y *= (1.0 - velocity.friction_y);
	}

	inline function update_neighbours()
	{
		is_wall_left = has_wall_tile_at(position.grid_x + 1, position.grid_y);
		is_wall_right = has_wall_tile_at(position.grid_x - 1, position.grid_y);
		is_wall_up = has_wall_tile_at(position.grid_x, position.grid_y - 1);
		is_wall_down = has_wall_tile_at(position.grid_x, position.grid_y + 1);
	}

	inline function update_gravity()
	{
		velocity.delta_y += gravity;
	}

	inline function update_collision()
	{
		// Left collision
		if (position.grid_cell_ratio_x >= 0.9 && is_wall_left)
		{
			position.grid_cell_ratio_x = 0.9; // clamp position
			velocity.delta_x = 0; // stop horizontal movement
		}

		// Right collision
		if (position.grid_cell_ratio_x <= 0.1 && is_wall_right)
		{
			position.grid_cell_ratio_x = 0.1; // clamp position
			velocity.delta_x = 0; // stop horizontal movement
		}

		// Ceiling collision
		if (position.grid_cell_ratio_y < 0.2 && is_wall_up)
		{
			position.grid_cell_ratio_y = 0.2; // clamp position
			velocity.delta_y = 0; // stop vertical movement
		}

		// Floor collision
		if (position.grid_cell_ratio_y >= 0.5 && is_wall_down)
		{
			position.grid_cell_ratio_y = 0.5; // clamp position
			velocity.delta_y = 0; // stop vertical movement
		}
	}

	inline function update_position()
	{
		// advance position.grid position if crossing edge
		while (position.grid_cell_ratio_x > 1)
		{
			position.grid_cell_ratio_x--;
			position.grid_x++;
		}
		while (position.grid_cell_ratio_x < 0)
		{
			position.grid_cell_ratio_x++;
			position.grid_x--;
		}

		// resulting position
		position.x = Math.floor((position.grid_x + position.grid_cell_ratio_x) * size.tile_size);

		// advance position.grid position if crossing edge
		while (position.grid_cell_ratio_y > 1)
		{
			position.grid_y++;
			position.grid_cell_ratio_y--;
		}
		while (position.grid_cell_ratio_y < 0)
		{
			position.grid_y--;
			position.grid_cell_ratio_y++;
		}

		// resulting position
		position.y = Math.floor((position.grid_y + position.grid_cell_ratio_y) * size.tile_size);
	}
}

@:structInit
class Position
{
	// tile map coordinates
	public var grid_x: Int;
	public var grid_y: Int;

	// ratios are 0.0 to 1.0  (position inside grid cell)
	public var grid_cell_ratio_x: Float;
	public var grid_cell_ratio_y: Float;

	// resulting pixel coordinates
	public var x: Float;
	public var y: Float;
}

@:structInit
class Velocity
{
	// applied to grid cell ratio each frame
	public var delta_x: Float = 0;
	public var delta_y: Float = 0;

	// friction applied each frame 0.0 for none, 1.0 for maximum
	public var friction_x: Float = 0.10;
	public var friction_y: Float = 0.06;
}

@:structInit
class Size
{
	public var tile_size: Int;
	public var radius: Float;
}

/*
	This extension of the base movement adds extra functionality typically found in platformer physics

	- predictable jump variables : intuitively adjust the height and duration of a jump to derive y velocity
	- control jump descent : release the jump button before jump apex to descend early
	- faster jump descent : descend from jump apex faster than ascent

	- coyote time : allows jump to be performed a short time after leaving the edge of platform
	- jump buffer : allows jump button press to to be registered before touching ground

 */
@:publicFields
class PlatformerMovement extends DeepnightMovement
{
	public var jump_config(default, null): JumpConfig;

	/** y velocity of jump ascent. measured in tiles per step **/
	var velocity_ascent: Float;

	/** y velocity of jump descent, measured in tiles per step**/
	var velocity_descent: Float;

	/** gravity to apply during jump ascent, measured in tiles per step **/
	var gravity_ascent: Float;

	/** gravity to apply during jump descent, measured in tiles per step **/
	var gravity_descent: Float;

	/** game steps remaining until jump buffer time ends**/
	var buffer_step_count_remaining: Int = 0;

	/** game steps remaining until coyote time ends**/
	var coyote_steps_remaining: Int = 0;

	/** true during the ascent and descent of a jump **/
	var is_jump_in_progress: Bool = false;

	var jump_steps_remaining: Int = 0;

	/** true when no vertical movement is possible towards floor **/
	var is_on_ground: Bool = true;

	public var state_previous: MovementState;

	public function new(grid_x: Int, grid_y: Int, tile_size: Int, has_wall_tile_at: (grid_x: Int, grid_y: Int) -> Bool)
	{
		super(grid_x, grid_y, tile_size, has_wall_tile_at);
		jump_config = {}

		// y velocity is determined by jump velocity and gravity so set friction to 0
		velocity.friction_y = 0;

		var jump_height = jump_config.height_tiles_max;
		// calculate gravity
		gravity_ascent = -(-2.0 * jump_height / (jump_config.ascent_step_count * jump_config.ascent_step_count));
		gravity_descent = -(-2.0 * jump_height / (jump_config.descent_step_count * jump_config.descent_step_count)) * 0.5;

		// calculate velocity
		velocity_ascent = -((2.0 * jump_height) / jump_config.ascent_step_count);
		velocity_descent = Math.sqrt(2 * gravity_descent * jump_config.height_tiles_min);
	}

	/** called from jump button or key press **/
	public function press_dash()
	{
		velocity.delta_x = 0.9;
	}

	/** called from jump button or key press **/
	public function press_jump()
	{
		// jump ascent phase can start if we are on the ground or coyote time did not finish

		var is_within_coyote_time = coyote_steps_remaining > 0;
		if (is_on_ground || is_within_coyote_time)
		{
			ascend();
		}
		else
		{
			// if jump was pressed but could not be performed begin jump buffer
			buffer_step_count_remaining = jump_config.buffer_step_count;
		}
	}

	/** called from jump button or key release **/
	public function release_jump()
	{
		descend();
	}

	/** begin jump ascent phase **/
	inline function ascend()
	{
		// set ascent velocity
		velocity.delta_y = velocity_ascent;

		// if we are in ascent phase then jump is in progress
		is_jump_in_progress = true;

		jump_steps_remaining = jump_config.ascent_step_count + jump_config.descent_step_count;

		// reset coyote time because we left the ground with a jump
		coyote_steps_remaining = 0;
	}

	/** begin jump descent phase **/
	inline function descend()
	{
		// set descent velocity
		velocity.delta_y = velocity_descent;
	}

	override function update()
	{
		/* 
			most of the update logic for the movement is called from the super class
			however we also perform extra jump logic
		 */

		// jump logic
		//------------

		// count down every step
		coyote_steps_remaining--;
		buffer_step_count_remaining--;

		if (is_on_ground)
		{
			// if we are on the ground then a jump is not in progress or has finished
			is_jump_in_progress = false;

			// reset coyote step counter every step that we are on the ground
			coyote_steps_remaining = jump_config.coyote_step_count;

			// jump ascent phase can be triggered if we are on the ground and jump buffer is in progress
			if (buffer_step_count_remaining > 0)
			{
				// trigger jump ascent phase
				ascend();
				// reset jump step counter because jump buffer has now ended
				buffer_step_count_remaining = 0;
			}
		}

		// movement logic
		//----------------

		// change position within grid cell by velocity
		super.update_movement_horizontal();
		super.update_movement_vertical();

		// check for adjacent tiles
		super.update_neighbours();

		// override gravity logic so use different values during jump
		override_update_gravity();

		// stop movement if colliding with a tile
		super.update_collision();
		// if delta_y is 0 and there is a wall tile below then movement stopped
		// because we collided with the ground
		is_on_ground = velocity.delta_y == 0 && is_wall_down;

		// update position within grid and cell
		super.update_position();
	}

	inline function override_update_gravity()
	{
		if (jump_steps_remaining > 0)
		{
			// gravity has different values depending on jump phase
			// ascent phase if delta_y is negative (moving towards ceiling)
			// descent phase if delta_y is positive (moving towards floor)

			// calculate gravity
			gravity_ascent = -(-2.0 * jump_config.height_tiles_max / (jump_steps_remaining * jump_steps_remaining));
			gravity_descent = -(-2.0 * jump_config.height_tiles_max / (jump_steps_remaining * jump_steps_remaining));
			gravity_ascent = jump_config.height_tiles_max / (2 * jump_steps_remaining * jump_steps_remaining);
			// calculate velocity
			velocity_ascent = -((2.0 * jump_config.height_tiles_max) / jump_config.ascent_step_count);
			velocity_descent = Math.sqrt(2 * gravity_descent * jump_config.height_tiles_min);

			// velocity.delta_y += velocity.delta_y <= 0 ? gravity_ascent : gravity_descent;
			velocity.delta_y += gravity_ascent;
			jump_steps_remaining--;
		}
		else
		{
			// use default gravity when jump is not in progress
			velocity.delta_y += gravity;
		}
	}
}

@:structInit
class JumpConfig
{
	/** maximum height of jump, measured in tiles **/
	public var height_tiles_max: Float = 3.0; // todo - is this a bug? appears to be double the distance

	/** minimum height of jump, measured in tiles **/
	public var height_tiles_min: Float = 2.5;

	/** duration of jump ascent time, measured in game update steps **/
	public var ascent_step_count = 12;

	/** duration of jump descent time, measured in game update steps **/
	public var descent_step_count = 7;

	/** duration of jump buffer time, measured in game steps**/
	public var buffer_step_count: Int = 15;

	/** duration of coyote time, measured in game steps**/
	public var coyote_step_count: Int = 5;
}

enum MovementState
{
	IDLE;
	ASCEND;
	DESCEND;
	MOVE_HORIZONTAL;
}
