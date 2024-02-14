package game;

import haxe.EnumTools;
import lib.lime.Audio;
import lib.peote.Elements;
import lib.peote.Glyph;
import lib.pure.Repeat;
import game.SamuraiStates;
import game.Sounds;

using lib.peote.TextureTools;

/** The main game entity, extended by Player and Guard **/
@:publicFields
class Samurai extends Actor
{
	var hitbox_debug: Fill;

	var frame_changer: Repeat;
	var animation: Animation;
	var animation_next: AnimationKey;
	var animation_frame = 0;
	var animation_index = 0;

	static var animation_sheet_columns = 10;
	static var animation_sheet_rows = 21;

	var states: Map<StateKey, State>;
	var state: State;
	var state_next: StateKey;
	var is_movement_button_held: Bool = false;
	var repeaters: Array<Repeat> = [];

	var icon: Tile;
	var icon_glyphs: GlyphLine;

	var thought_glyphs: GlyphLine;
	var has_thought: Bool = false;
	var thought: String = "";
	var sound: SoundManager;
	var thought_clearer: Repeat;

	public function new(sound: SoundManager, glyphs: GlyphLine, thought_glyphs: GlyphLine, states: Map<StateKey, State>, hitbox_debug: Fill, sprite: Sprite,
			grid_x: Int, grid_y: Int, cell_size_px: Int, has_wall_tile_at: (grid_x: Int, grid_y: Int) -> Bool)
	{
		this.sound = sound;
		this.icon_glyphs = glyphs;
		this.icon = glyphs.tiles[0];
		this.thought_glyphs = thought_glyphs;
		this.states = states;
		this.hitbox_debug = hitbox_debug;
		super(sprite, grid_x, grid_y, cell_size_px, has_wall_tile_at);

		frame_changer = {
			duration: 2, // every 2 game steps
			action: repeat -> show_next_animation_frame()
		}

		thought_clearer = {
			duration: Std.int(30 * 2.0),
			action: repeat -> clear_thought()
		}

		repeaters.push(thought_clearer);

		state_next = IDLE;
		change_state(state_next);

		animation_next = CROUCH_IDLE;
		change_animation(animation_next);

		movement.velocity.friction_x = 0.65;
		velocity_y_max = 0.99;
		facing = 1;
	}

	override function move_in_direction_x(direction: Int)
	{
		super.move_in_direction_x(direction);

		if (!movement.is_jump_in_progress)
		{
			state.key_next = WALK;
		}
	}

	override function stop_x()
	{
		super.stop_x();
		state.key_next = IDLE;
	}

	override function jump()
	{
		super.jump();

		if (movement.is_jump_in_progress)
		{
			state.key_next = JUMP;
		}
	}

	override function dash()
	{
		if (state.key != ROLL_GROUND)
		{
			super.dash();
			state.key_next = ROLL_GROUND;
		}
	}

	function show_next_animation_frame()
	{
		animation_frame = switch animation.mode
		{
			case LOOPED: (animation_frame + 1) % animation.frame_count;
			case FRAME: animation_next == AIRSPIN || animation.key == AIRSPIN ? (animation_frame + 1) % animation.frame_count : animation_frame;
			case _:
				Std.int(Math.min(animation_frame + 1, animation.frame_count - 1));
		}

		if (animation.key == DEATH && animation_frame == 3)
		{
			sound.play_sound(SoundKey.DIE);
		}

		sprite.tile_index = animation_frame + animation_sheet_columns * animation_index;
	}

	override function draw(step_ratio: Float)
	{
		super.draw(step_ratio);
		icon.x = sprite.x;
		icon.y = sprite.y - 24;
	}

	override function update()
	{
		super.update();
		for (repeat in repeaters)
		{
			repeat.update();
		}

		hitbox_debug.x = movement.position.x;
		hitbox_debug.y = movement.position.y;

		state_next = state.update();

		if (state_next != state.key)
		{
			if (animation.mode != ONCE)
			{
				change_state(state_next);
			}
			else
			{
				if (animation_frame >= animation.frame_count - 1)
				{
					// if a roll is in progress, stop moving unless movement button is pressed
					if (state.key == ROLL_GROUND && !is_movement_button_held)
					{
						stop_x();
					}

					change_state(state_next);
				}
			}
		}

		frame_changer.update();

		if (animation_next != animation.key)
		{
			if (animation.mode == ONCE && animation_frame < animation.frame_count - 1) {}
			else
			{
				change_animation(animation_next);
			}
		}
	}

	function change_animation(animation_key: AnimationKey)
	{
		animation = Data.animations[animation_key];
		animation_index = EnumValueTools.getIndex(animation_key);
		animation_frame = 0;
	}

	function change_state(state_key: StateKey)
	{
		if (states.exists(state_key))
		{
			state = states[state_key];
			state.on_state_enter();
		}
	}

	public function is_vulnerable(): Bool
	{
		return state.key != DEATH && state.key != HURT && state.key_next != HURT && state.key != ROLL_GROUND;
	}

	function show_thought(thought: String)
	{
		this.thought = thought;
		has_thought = true;
		thought_glyphs.change_text(thought);
		thought_glyphs.change_tint(0x000000FF);
		thought_clearer.remaining = thought_clearer.duration;
	}

	function clear_thought()
	{
		thought = " ";
		has_thought = false;
		thought_glyphs.change_text(thought);
		thought_glyphs.change_tint(0x00000000);
	}

	public function play_sound(key: SoundKey)
	{
		sound.play_sound(key);
	}
}

@:structInit
@:publicFields
class Animation
{
	var key: AnimationKey;
	var mode: AnimationMode;
	var frame_count: Int;
}

enum AnimationMode
{
	LOOPED;
	ONCE;
	FRAME;
}

enum AnimationKey
{
	AIRSPIN;
	CROUCH_IDLE;
	CROUCH_WALK;
	DEATH;
	HURT;
	IDLE;
	JUMP;
	LAND;
	LEDGE;
	PULL;
	PUNCH;
	PUSH;
	PUSH_IDLE;
	ROLL;
	RUN;
	SWORD_ATTACK;
	SWORD_IDLE;
	SWORD_RUN;
	SWORD_STAB;
	WALK;
	WALL_LAND;
	WALL_SLIDE;
}

@:publicFields
class Data
{
	static var animations: Map<AnimationKey, Animation> = [
		AIRSPIN => {
			key: AIRSPIN,
			mode: LOOPED,
			frame_count: 6
		},
		CROUCH_IDLE => {
			key: CROUCH_IDLE,
			mode: LOOPED,
			frame_count: 10
		},
		CROUCH_WALK => {
			key: CROUCH_WALK,
			mode: LOOPED,
			frame_count: 10
		},
		DEATH => {
			key: DEATH,
			mode: ONCE,
			frame_count: 10
		},
		HURT => {
			key: HURT,
			mode: ONCE,
			frame_count: 4
		},
		IDLE => {
			key: IDLE,
			mode: LOOPED,
			frame_count: 10
		},
		JUMP => {
			key: JUMP,
			mode: FRAME,
			frame_count: 3
		},
		LAND => {
			key: LAND,
			mode: ONCE,
			frame_count: 3
		},
		LEDGE => {
			key: LEDGE,
			mode: ONCE,
			frame_count: 5
		},
		PULL => {
			key: PULL,
			mode: LOOPED,
			frame_count: 6
		},
		PUNCH => {
			key: PUNCH,
			mode: ONCE,
			frame_count: 8
		},
		PUSH => {
			key: PUSH,
			mode: LOOPED,
			frame_count: 10
		},
		PUSH_IDLE => {
			key: PUSH_IDLE,
			mode: LOOPED,
			frame_count: 8
		},
		ROLL => {
			key: ROLL,
			mode: ONCE,
			frame_count: 7
		},
		RUN => {
			key: RUN,
			mode: LOOPED,
			frame_count: 8
		},
		SWORD_ATTACK => {
			key: SWORD_ATTACK,
			mode: ONCE,
			frame_count: 6
		},
		SWORD_IDLE => {
			key: SWORD_IDLE,
			mode: LOOPED,
			frame_count: 10
		},
		SWORD_RUN => {
			key: SWORD_RUN,
			mode: LOOPED,
			frame_count: 8
		},
		SWORD_STAB => {
			key: SWORD_STAB,
			mode: ONCE,
			frame_count: 7
		},
		WALK => {
			key: WALK,
			mode: LOOPED,
			frame_count: 8
		},
		WALL_LAND => {
			key: WALL_LAND,
			mode: ONCE,
			frame_count: 6
		},
		WALL_SLIDE => {
			key: WALL_SLIDE,
			mode: ONCE,
			frame_count: 3
		}
	];
}
