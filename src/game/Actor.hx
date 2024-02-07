package game;

import lib.peote.Elements;
import lib.pure.Calculate;
import lib.pure.Deepnight;

using lib.peote.TextureTools;

@:publicFields
class Actor
{
	public var sprite(default, null): Sprite;
	public var movement(default, null): PlatformerMovement;

	var position_x_previous: Float;
	var position_y_previous: Float;

	public var direction_x: Int = 0;
	public var facing: Int = 0;
	public var is_moving_x(get, never): Bool;

	function get_is_moving_x(): Bool
	{
		return direction_x != 0;
	}

	var acceleration_x: Float = 0.15;

	public var velocity_x_max: Float = 0.62;
	public var velocity_y_max: Float = 0.7;

	var is_jumping: Bool = false;
	var jump_velocity: Float = -0.85;

	public function new(sprite: Sprite, grid_x: Int, grid_y: Int, cell_size_px: Int, has_wall_tile_at: (grid_x: Int, grid_y: Int) -> Bool)
	{
		this.sprite = sprite;
		movement = new PlatformerMovement(grid_x, grid_y, cell_size_px, has_wall_tile_at);
		movement.velocity.friction_y = 0;
		position_x_previous = movement.position.x;
		position_y_previous = movement.position.y;
	}

	public function update()
	{
		if (direction_x != 0)
		{
			// accelerate horizontally
			movement.velocity.delta_x += (direction_x * acceleration_x);
			if (direction_x != 0)
			{
				facing = direction_x;
			}
		}

		// cap speed
		if (movement.velocity.delta_x > velocity_x_max)
		{
			movement.velocity.delta_x = velocity_x_max;
		}
		if (movement.velocity.delta_x < -velocity_x_max)
		{
			movement.velocity.delta_x = -velocity_x_max;
		}

		if (velocity_y_max > 0 && movement.velocity.delta_y > velocity_y_max)
		{
			movement.velocity.delta_y = velocity_y_max;
		}
		if (velocity_y_max < 0 && movement.velocity.delta_y < -velocity_y_max)
		{
			movement.velocity.delta_y = -velocity_y_max;
		}

		position_x_previous = movement.position.x;
		position_y_previous = movement.position.y;

		movement.update();
	}

	public function draw(step_ratio: Float)
	{
		sprite.x = lerp(
			position_x_previous,
			movement.position.x,
			step_ratio
		);
		sprite.y = lerp(
			position_y_previous,
			movement.position.y,
			step_ratio
		);
		sprite.facing_x = facing;
	}

	public function move_in_direction_x(direction: Int)
	{
		facing = direction;
		direction_x = direction;
		// movement.state = MOVE_HORIZONTAL;
	}

	public function stop_x()
	{
		direction_x = 0;
		// movement.state = IDLE;
	}

	public function dash()
	{
		movement.press_dash();
	}

	public function jump()
	{
		movement.press_jump();
	}

	public function drop()
	{
		movement.release_jump();
	}

	public function is_in_cell(column: Int, row: Int)
	{
		return movement.position.grid_x == column && movement.position.grid_y == row;
	}
}
