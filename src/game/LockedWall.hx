package game;

import lib.peote.Elements;
import lib.peote.Glyph;
import lib.pure.Calculate;

/** Level blocks which are "locked" and need a key to pass **/
@:publicFields
class LockedWall
{
	var locked_walls: Array<Fill> = [];
	var is_locked: Bool;
	var key_glyphs: GlyphLine;
	var key: Tile;
	var fills: Fills;
	var key_hole: GlyphLine;

	function new(fills: Fills)
	{
		is_locked = true;
		this.fills = fills;
	}

	function add_block(fill: Fill)
	{
		locked_walls.push(fill);
	}

	function unlock()
	{
		is_locked = false;
		for (fill in locked_walls)
		{
			fill.tint.a = 0x00;
			fills.update_element(fill);
		}

		key_hole.change_tint(0x00);
	}

	function add_key(key_glyphs: GlyphLine)
	{
		this.key_glyphs = key_glyphs;
		this.key = key_glyphs.tiles[0];
	}

	public function is_overlapping_key(x: Float, y: Float): Bool
	{
		return key != null && distance_to_point(key.x, key.y, x, y) <= 16;
	}

	public function hide_key()
	{
		key.tint.a = 0x00;
	}

	public function reset()
	{
		is_locked = true;
		key.tint.a = 0xff;
		for (fill in locked_walls)
		{
			fill.tint.a = 0xff;
			fills.update_element(fill);
		}
		key_hole.change_tint(0xff);
	}

	public function add_key_hole(glyph: GlyphLine)
	{
		this.key_hole = glyph;
	}
}
