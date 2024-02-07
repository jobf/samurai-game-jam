package lib.peote;

import peote.view.Buffer;
import peote.view.Color;
import peote.view.Display;
import peote.view.Element;
import peote.view.Program;
import peote.view.Texture;

class Fill implements Element
{
	// position in pixel  (relative to upper left corner of Display)
	@posX public var x: Float;
	@posY public var y: Float;

	// offset center position
	@pivotX @formula("width * offset_x + px_offset") public var px_offset: Float = 0.0;
	@pivotY @formula("height * offset_y + py_offset") public var py_offset: Float = 0.0;

	@custom public var offset_x: Float = 0.5;
	@custom public var offset_y: Float = 0.5;

	@sizeX @varying public var width: Int;

	@sizeY @varying public var height: Int;

	@custom @varying public var scroll_offset_x: Float = 0.0;
	@custom @varying public var scroll_offset_y: Float = 0.0;

	@rotation public var angle: Float = 0.0;

	// RGBA
	@color @varying public var tint: Color;

	@texTile public var tile_index: Int = 0;

	var OPTIONS = {blend: true};

	var is_center_pivot: Bool;

	public function new(x: Float, y: Float, width: Float, height: Float, tint: Color = 0xffffffFF, is_center_pivot: Bool = true)
	{
		this.x = Std.int(x);
		this.y = Std.int(y);

		this.width = Std.int(width);
		this.height = Std.int(height);

		this.tint = tint;

		this.is_center_pivot = is_center_pivot;
		if (is_center_pivot)
		{
			offset_x = 0.5;
			offset_y = 0.5;
		}
		else
		{
			offset_x = 0.0;
			offset_y = 0.0;
		}
	}
}

@:publicFields
class Fills
{
	private var buffer: Buffer<Fill>;
	private var program: Program;

	function new(display: Display, buffer_size: Int = 256)
	{
		buffer = new Buffer<Fill>(buffer_size, buffer_size, true);
		program = new Program(buffer);
		program.snapToPixel(1);
		display.addProgram(program);
	}

	function make(x: Float, y: Float, size: Float, is_center_pivot: Bool = true, tint: Int = 0xf0f0f0ff): Fill
	{
		var element = new Fill(Std.int(x), Std.int(y), Std.int(size), Std.int(size), tint, is_center_pivot);
		buffer.addElement(element);
		return element;
	}

	function make_aligned(column: Float, row: Float, align_px: Float, width_px: Float, height_px: Float, tint: Int): Fill
	{
		var element = new Fill(
			Std.int(column * align_px),
			Std.int(row * align_px),
			Std.int(width_px),
			Std.int(height_px),
			tint,
			false
		);

		element.offset_x = 0;
		element.offset_y = 0;

		buffer.addElement(element);
		return element;
	}

	function update_element(element: Fill)
	{
		buffer.updateElement(element);
	}

	function update_all()
	{
		buffer.update();
	}

	public function set_fragment_shader(fragment: String, color_formula: String)
	{
		program.injectIntoFragmentShader(fragment);
		program.setColorFormula(color_formula);
	}

	public function clear()
	{
		buffer.clear();
	}
}

@:publicFields
class Tiles
{
	private var buffer: Buffer<Tile>;
	private var program: Program;
	var tile_size_px: Int;
	var texture: Texture;
	var total: Int = 0;

	function new(display: Display, texture: Texture, unique_id: String, tile_size_px: Int, buffer_page_size: Int = 256)
	{
		this.texture = texture;
		this.tile_size_px = tile_size_px;

		buffer = new Buffer<Tile>(buffer_page_size, buffer_page_size, true);

		program = new Program(buffer);
		program.blendEnabled = true;
		program.snapToPixel(1);
		program.addToDisplay(display);
		program.addTexture(texture, unique_id);
		display.addProgram(program);
	}

	function make(x: Float, y: Float, width: Float, height: Float, tile_index: Int, is_flipped_x: Bool = false): Tile
	{
		var element = new Tile(Std.int(x), Std.int(y), Std.int(width), Std.int(height), tile_index, 0xffffffff, is_flipped_x);

		buffer.addElement(element);
		total++;
		return element;
	}

	function make_aligned(column: Int, row: Int, align_px: Int, tile_index: Int, is_flipped_x: Bool): Tile
	{
		return make(column * align_px, row * align_px, tile_size_px, tile_size_px, tile_index, is_flipped_x);
	}

	function update_element(element: Tile)
	{
		buffer.updateElement(element);
	}

	function update_all()
	{
		buffer.update();
	}

	public function clear()
	{
		buffer.clear();
	}
}

class Tile implements Element
{
	/**
		pixel position of the left edge
	**/
	@posX public var x: Float;

	/**
		pixel position of the top edge
	**/
	@posY public var y: Float;

	/**
		pixel width
	**/
	@varying @sizeX public var w: Int;

	/**
		pixel height
	**/
	@varying @sizeY public var h: Int;

	/**
		refers to the index of the tile within a large texture that has been partitioned
	**/
	@texTile() public var tile_index: Int;

	/**
		a color which tints the tile, for easy tinting the raw tile data to be tinted should be white
	**/
	@color public var tint: Color;

	public function new(x: Float, y: Float, width: Int, height: Int, tile_index: Int, tint: Color = 0xffffffff, flip_x: Bool = false)
	{
		this.x = x;
		this.y = y;
		this.w = width;
		this.h = height;
		if (flip_x)
		{
			this.w = -width;
			this.x += width;
		}
		this.tile_index = tile_index;
		this.tint = tint;
	}
}

class Sprite implements Element
{
	// position in pixel  (relative to upper left corner of Display)
	@posX public var x: Float;
	@posY public var y: Float;

	// offset center position
	@pivotX @formula("(width * facing_x) * offset_x + px_offset") public var px_offset: Float = 0.0;
	@pivotY @formula("height * offset_y + py_offset") public var py_offset: Float = 0.0;

	@custom public var offset_x: Float = 0.5;
	@custom public var offset_y: Float = 0.5;

	@sizeX @varying @formula("width * facing_x") var x_size: Float;

	@varying @sizeY public var height: Float;

	@custom @varying public var width: Float;
	@custom @varying public var facing_x: Int = 1;

	@rotation public var angle: Float = 0.0;
	// RGBA
	@color public var tint: Color = 0xffffffFF;
	@texTile() public var tile_index: Int;

	var OPTIONS = {blend: true};

	public function new(x: Int, y: Int, width: Int, height: Int, tile_index: Int = 0)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.tile_index = tile_index;
	}
}

/**
	Designed for use with Textures that are a "sprite sheet" of equally sized square sprites
**/
@:publicFields
class Sprites
{
	private var buffer: Buffer<Sprite>;
	private var program: Program;
	var tile_size_px: Int;
	var texture: Texture;
	var total: Int = 0;

	function new(display: Display, texture: Texture, unique_id: String, tile_size_px: Int, buffer_page_size: Int = 256)
	{
		this.tile_size_px = tile_size_px;

		buffer = new Buffer<Sprite>(buffer_page_size, buffer_page_size, true);

		program = new Program(buffer);
		program.blendEnabled = true;
		program.addToDisplay(display);
		program.addTexture(texture, unique_id);
		program.snapToPixel(1);
		display.addProgram(program);
	}

	function make(x: Float, y: Float, tile_index: Int, is_center_pivot: Bool = true): Sprite
	{
		var element = new Sprite(Std.int(x), Std.int(y), tile_size_px, tile_size_px, tile_index);

		buffer.addElement(element);

		total++;

		return element;
	}

	function make_aligned(column: Int, row: Int, align_px: Int, tile_index: Int, is_center_pivot: Bool = true): Sprite
	{
		return make(column * align_px, row * align_px, tile_index, is_center_pivot);
	}

	function update_element(element: Sprite)
	{
		buffer.updateElement(element);
	}

	function update_all()
	{
		buffer.update();
	}

	public function clear()
	{
		buffer.clear();
	}
}
