package game;

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
}
