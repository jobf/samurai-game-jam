package game;

import game.Samurai;
import game.Sounds;

class StateIdle extends State
{
	public function new(samurai: Samurai)
	{
		super(IDLE, samurai);
	}

	public function update(): StateKey
	{
		return key_next;
	}

	override function on_state_enter()
	{
		super.on_state_enter();
		samurai.animation_next = IDLE;
		samurai.movement.velocity.friction_x = 0.65;
		samurai.velocity_x_max = 0.2;
		samurai.acceleration_x = 0.15;
	}
}

class StateJump extends State
{
	public function new(samurai: Samurai)
	{
		super(JUMP, samurai);
	}

	public function update(): StateKey
	{
		if (samurai.movement.is_on_ground)
		{
			key_next = IDLE;
		}
		else
		{
			key_next = JUMP;

			var jump_steps = (samurai.movement.jump_config.ascent_step_count + samurai.movement.jump_config.descent_step_count)
				- samurai.movement.jump_steps_remaining;
			if (jump_steps > 3 && samurai.animation.key != AIRSPIN)
			{
				samurai.animation_next = AIRSPIN;
				samurai.change_animation(AIRSPIN);
			}

			if (samurai.movement.steps_remaining_before_apex <= 0)
			{
				samurai.animation_next = AnimationKey.JUMP;
				samurai.change_animation(AnimationKey.JUMP);
				samurai.animation_frame = 2;
			}
		}

		return key_next;
	}

	override function on_state_enter()
	{
		super.on_state_enter();
		samurai.animation_next = JUMP;
	}
}

class StateWalk extends State
{
	public function new(samurai: Samurai)
	{
		super(WALK, samurai);
	}

	public function update(): StateKey
	{
		if (samurai.direction_x == 0 && key_next == WALK)
		{
			key_next = IDLE;
		}

		return key_next;
	}

	override function on_state_enter()
	{
		samurai.animation_next = WALK;
		super.on_state_enter();

		samurai.movement.velocity.friction_x = 0.65;
		samurai.velocity_x_max = 0.2;
		samurai.acceleration_x = 0.15;
	}
}

class StateLand extends State
{
	public function new(samurai: Samurai)
	{
		super(LAND, samurai);
	}

	public function update(): StateKey
	{
		if (samurai.movement.is_on_ground)
		{
			key_next = IDLE;
		}

		return key_next;
	}

	override function on_state_enter()
	{
		super.on_state_enter();
		samurai.animation_next = LAND;
		samurai.movement.velocity.friction_x = 0.65;
		samurai.velocity_x_max = 0.2;
		samurai.acceleration_x = 0.15;
	}
}

class StateRollGround extends State
{
	public function new(samurai: Samurai)
	{
		super(ROLL_GROUND, samurai);
	}

	public function update(): StateKey
	{
		return key_next;
	}

	override function on_state_enter()
	{
		samurai.animation_next = ROLL;
		samurai.movement.velocity.friction_x = 0.2;
		samurai.velocity_x_max = 0.45;
		samurai.acceleration_x = 0.60;
		samurai.move_in_direction_x(samurai.facing);
		key_next = CROUCH;
	}
}

class StateCrouch extends State
{
	public function new(samurai: Samurai)
	{
		super(CROUCH, samurai);
	}

	public function update(): StateKey
	{
		if (samurai.movement.velocity.delta_y > 0)
		{
			// show 'falling' animation fram of jump animation
			samurai.animation_next = JUMP;
			samurai.change_animation(JUMP);
			samurai.animation_frame = 2;
		}
		else
		{
			samurai.animation_next = CROUCH_IDLE;
			if (samurai.movement.velocity.delta_x != 0)
			{
				samurai.animation_next = key_next == ROLL_GROUND ? ROLL : CROUCH_WALK;
			}
		}

		return key_next;
	}

	override function on_state_enter()
	{
		super.on_state_enter();
		samurai.animation_next = CROUCH_IDLE;
		samurai.movement.velocity.friction_x = 0.65;
		samurai.velocity_x_max = 0.2;
		samurai.acceleration_x = 0.15;
	}
}

class StateSword extends State
{
	public function new(samurai: Samurai)
	{
		super(SWORD, samurai);
	}

	override function on_state_enter()
	{
		super.on_state_enter();
		samurai.animation_next = SWORD_STAB;
	}

	public function update(): StateKey
	{
		return IDLE;
	}
}

class StateHurt extends State
{
	public function new(samurai: Samurai)
	{
		super(HURT, samurai);
	}

	override function on_state_enter()
	{
		super.on_state_enter();
		samurai.animation_next = HURT;
		samurai.play_sound(SoundKey.HURT_A);
	}

	public function update(): StateKey
	{
		return DEATH;
	}
}

class StateDeath extends State
{
	public function new(samurai: Samurai)
	{
		super(DEATH, samurai);
	}

	override function on_state_enter()
	{
		super.on_state_enter();
		samurai.animation_next = DEATH;
	}

	public function update(): StateKey
	{
		return DEATH;
	}
}

enum StateKey
{
	IDLE;
	WALK;
	RUN;
	CROUCH;
	JUMP;
	FALL;
	LAND;
	GRAB;
	CLIMB;
	SWORD;
	ROLL_GROUND;
	ROLL_AIR;
	HURT;
	DEATH;
}

@:publicFields
abstract class State
{
	var key: StateKey;
	var key_next: StateKey;
	var samurai: Samurai;

	function new(key: StateKey, samurai: Samurai)
	{
		this.key = key;
		this.key_next = key;
		this.samurai = samurai;
	}

	function on_state_enter()
	{
		key_next = key;
		trace('enter state $key_next');
	}

	abstract function update(): StateKey;
}
