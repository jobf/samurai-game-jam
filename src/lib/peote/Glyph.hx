package lib.peote;

import lib.peote.Elements;
import lime.utils.Assets;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Display;
import peote.view.Program;
import peote.view.Texture;

@:publicFields
class Glyphs
{
	var font: FontModel;
	var char_map: Map<Int, Int>;
	var buffer: Buffer<Tile>;
	var program: Program;
	var texture: Texture;
	var texture_name: String;

	public function new(display: Display, font: FontModel)
	{
		this.font = font;
		char_map = [];
		for (i in 0...font.char_map.length)
		{
			char_map.set(font.char_map.charCodeAt(i), i);
		}

		buffer = new Buffer<Tile>(font.element_count);
		program = new Program(buffer);
		program.blendEnabled = true;
		program.addToDisplay(display);

		var image = Assets.getImage(font.tile_asset_path);
		texture = new Texture(image.width, image.height);
		texture.tilesX = Std.int(image.width / font.tile_width);
		texture.tilesY = Std.int(image.height / font.tile_height);
		texture.setImage(image, 0);
		texture_name = StringTools.replace(
			font.tile_asset_path,
			"/",
			"_"
		);
		texture_name = StringTools.replace(texture_name, "-", "_");
		texture_name = StringTools.replace(texture_name, ".", "_");
		program.addTexture(texture, texture_name);
	}

	public function make_line(x: Int, y: Int, text: String, tint: Int): GlyphLine
	{
		return {
			text: text,
			glyphs: this,
			tiles: [
				for (index in 0...text.length)
					buffer_tile(
						x,
						y,
						index,
						char_map[text.charCodeAt(index)],
						tint
					)
			]
		};
	}

	public function buffer_tile(line_x: Float, line_y: Float, index: Int, char_code: Int, tint: Color): Tile
	{
		var tile = new Tile(
			Std.int((index * font.element_width) + line_x),
			line_y,
			font.tile_width,
			font.tile_height,
			char_code,
			tint
		);

		buffer.addElement(tile);

		return tile;
	}

	public function update()
	{
		buffer.update();
	}

	inline public function char_tile_index(char_code: Int): Int
	{
		return char_map[char_code];
	}

	public function update_tile(tile: Tile)
	{
		buffer.updateElement(tile);
	}

	public function change_tint(tiles: Array<Tile>, tint: Int)
	{
		for (tile in tiles)
		{
			tile.tint = tint;
		}
		buffer.update();
	}

	public function clear_all()
	{
		buffer.clear();
	}
}

@:structInit
@:publicFields
class GlyphLine
{
	private var glyphs: Glyphs;
	var tiles: Array<Tile>;
	var text: String;
	var width(get, never): Int;
	var height(get, never): Int;

	function move(x: Int, y: Int)
	{
		var width = tiles[0].w;
		for (i => tile in tiles)
		{
			tile.x = x + (width * i);
			tile.y = y;
			glyphs.update_tile(tile);
		}
	}

	public function change_text(text: String)
	{
		this.text = text;
		var line_x = tiles[0].x;
		var line_y = tiles[0].y;
		var tint = tiles[0].tint;

		if (tiles.length > text.length)
		{
			for (tile in tiles)
			{
				tile.tile_index = glyphs.char_tile_index(30);
				glyphs.update_tile(tile);
			}
		}
		for (i in 0...text.length)
		{
			if (i > tiles.length - 1)
			{
				tiles.push(glyphs.buffer_tile(
					line_x,
					line_y,
					i,
					glyphs.char_tile_index(text.charCodeAt(i)),
					tint
				));
			}
			else
			{
				tiles[i].tile_index = glyphs.char_tile_index(text.charCodeAt(i));
				glyphs.update_tile(tiles[i]);
			}
		}
	}

	public function change_tint(tint: Int)
	{
		glyphs.change_tint(tiles, tint);
	}

	function get_width(): Int
	{
		if (tiles.length > 0)
		{
			return tiles.length * tiles[0].w;
		}
		return 0;
	}

	function get_height(): Int
	{
		if (tiles.length > 0)
		{
			return tiles.length * tiles[0].h;
		}
		return 0;
	}

	public function center_on(x: Float, y: Float)
	{
		move(Std.int(x - width / 2), Std.int(y));
	}
}

@:structInit
@:publicFields
class FontModel
{
	var tile_width: Int;
	var tile_height: Int;
	var tile_asset_path: String;
	var element_width: Int;
	var element_height: Int;
	var element_count: Int = 1024;
	var char_map: String = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^`£abcdefghijklmnopqrstuvwxyz{|}~";
}
