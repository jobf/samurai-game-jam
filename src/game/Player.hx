package game;

import lib.pure.Calculate;
import lib.lime.Audio;
import lib.peote.Elements;
import lib.peote.Glyph;
import game.SamuraiStates;
import game.Sounds;

/**
	This is the Player, controlled by manual input (keyboard/gamepad)
**/
class Player extends Samurai
{
	var is_holding_key: Bool = false;
	var is_holding_sacred_stone: Bool = false;
	var attackers: Array<Guard> = [];

	public function new(sound: SoundManager, icon_glyphs: GlyphLine, thought_glyphs: GlyphLine, hitbox_debug: Fill, sprite: Sprite, grid_x: Int, grid_y: Int,
			tile_size_px: Int, has_wall_tile_at: (grid_x: Int, grid_y: Int) -> Bool)
	{
		trace('PLAYER');
		super(
			sound,
			icon_glyphs,
			thought_glyphs,
			[
				IDLE => new StateCrouch(this),
				JUMP => new StateJump(this),
				WALK => new StateCrouch(this),
				LAND => new StateLand(this),
				CROUCH => new StateCrouch(this),
				ROLL_GROUND => new StateRollGround(this),
				HURT => new StateHurt(this),
				DEATH => new StateDeath(this),
			],
			hitbox_debug,
			sprite,
			grid_x,
			grid_y,
			tile_size_px,
			has_wall_tile_at
		);
		repeaters.push({
			duration: 0,
			action: repeat ->
			{
				if (state.key != HURT && state.key != DEATH)
				{
					var attack_count = attackers.length;
					while (attack_count-- > 0)
					{
						var guard = attackers[attack_count];
						var direction_of_player = movement.position.x > guard.movement.position.x ? 1 : -1;
						var is_facing_player = guard.facing == direction_of_player;
						if (!is_facing_player)
						{
							// cannot hurt the player if guard is facing wrong direction
							continue;
						}

						var distance_to_player = distance_to_point(
							movement.position.x,
							movement.position.y,
							guard.movement.position.x,
							guard.movement.position.y
						);
						final attack_distance = 30;
						if (guard.state.key == SWORD && guard.animation_frame >= 4 && distance_to_player <= attack_distance)
						{
							// hurt player if close enough and sword animation is at appropriate frame
							stop_x();
							state.key_next = HURT;
							attackers.remove(guard);
						}
					}
				}
			}
		});
	}

	public function collect_sacred_stone()
	{
		sound.play_sound(SoundKey.COLLECT);
		is_holding_sacred_stone = true;
		icon_glyphs.change_text("*");
		icon.tint = 0xfb0073ff;
		show_thought("I MUST RETURN THE STONE");
	}

	public function collect_key()
	{
		sound.play_sound(SoundKey.COLLECT);
		is_holding_key = true;
		icon_glyphs.change_text("#");
		icon.tint = 0xe8a40aff;
	}

	public function reset()
	{
		is_holding_key = false;
		if (is_holding_sacred_stone)
		{
			icon_glyphs.change_text("*");
			icon.tint = 0xfb0073ff;
		}
		else
		{
			icon_glyphs.change_text(" ");
			icon.tint = 0x00000000;
		}
	}

	public function hide_icon()
	{
		icon_glyphs.change_text(" ");
		icon.tint = 0x00000000;
	}

	override function draw(step_ratio: Float)
	{
		super.draw(step_ratio);
		thought_glyphs.center_on(sprite.x, sprite.y - 48);
	}

	public function is_in_rectangle(x: Float, y: Float, width: Float, height: Float)
	{
		return movement.position.x > x
			&& movement.position.y > y
			&& movement.position.x < x + width
			&& movement.position.y < y + height;
	}

	public function add_attacker(samurai: Guard)
	{
		attackers.push(samurai);
	}
}
