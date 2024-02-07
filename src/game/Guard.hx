package game;

import lib.lime.Audio;
import lib.peote.Elements;
import lib.peote.Glyph;
import game.LdtkData;
import game.SamuraiStates;

/**
	This is the "Enemy" class, it is similar to the Player but controlled by simple AI rather than manual input
**/
class Guard extends Samurai
{
	public var ldtk_entity: Entity_Guard;

	public var is_alert: Bool;

	public function new(sound: SoundManager, glyphs: GlyphLine, thought_glyphs: GlyphLine, ldtk_entity: Entity_Guard, hitbox_debug: Fill, sprite: Sprite,
			grid_x: Int, grid_y: Int, tile_size_px: Int, has_wall_tile_at: (grid_x: Int, grid_y: Int) -> Bool)
	{
		trace('GUARD');
		this.ldtk_entity = ldtk_entity;
		sprite.tint = 0xb03a48FF;
		
		super(
			sound,
			glyphs,
			thought_glyphs,
			[
				IDLE => new StateIdle(this),
				JUMP => new StateJump(this),
				WALK => new StateWalk(this),
				LAND => new StateLand(this),
				CROUCH => new StateCrouch(this),
				ROLL_GROUND => new StateRollGround(this),
				SWORD => new StateSword(this),
			],
			hitbox_debug,
			sprite,
			grid_x,
			grid_y,
			tile_size_px,
			has_wall_tile_at
		);

		this.facing = ldtk_entity.f_facing;
		state_next = ldtk_entity.f_pose == Crouch ? CROUCH : IDLE;
		change_state(state_next);
		set_alertness(false);
		repeaters.push({
			duration: 2 * 30,
			action: repeat ->
			{
				if (is_alert)
				{
					set_alertness(false);
				}
			}
		});
	}

	public function reset()
	{
		this.facing = ldtk_entity.f_facing;
		state_next = ldtk_entity.f_pose == Crouch ? CROUCH : IDLE;
		change_state(state_next);
		movement.teleport_to_grid(ldtk_entity.cx, ldtk_entity.cy);
		set_alertness(false);
	}

	public function set_alertness(is_alert: Bool)
	{
		this.is_alert = is_alert;
		if (is_alert)
		{
			icon.tint = 0xff0010a0;
			icon_glyphs.change_text("!");
		}
		else
		{
			icon.tint = 0x800002a0;
			icon_glyphs.change_text(" ");
		}
	}
}
