package game;

import game.Scene.GameCore;
import lib.input2action.Controller;
import lib.peote.Elements;
import lib.peote.Glyph;
import lib.peote.Mouse.HotSpot;
import lib.pure.Ease;
import lib.pure.Transformation;
import lime.utils.Assets;
import peote.ui.PeoteUIDisplay;
import peote.view.Display;

using lib.peote.TextureTools;

class Shutter
{
	var ease: Ease;

	var glyphs: Glyphs;
	var message_color = 0xe0c872ff;

	public var is_closing(default, null): Bool;
	public var is_closed(default, null): Bool;
	public var is_opening(default, null): Bool;
	public var is_open(default, null): Bool;

	var on_open_complete: Null<() -> Void>;
	var on_close_complete: Null<() -> Void>;

	var hot_spot: HotSpot;
	var message: GlyphLine;
	var controller: ControllerActions;
	var scene_controller: ControllerActions;
	var core: GameCore;

	public function new(core: GameCore)
	{
		this.core = core;
		controller = {}

		is_closed = true;
		is_closing = false;
		is_open = false;
		is_opening = false;
		ease = new Ease(0.0, 1.0, 25, smooth_start_2);

		var title_asset = Assets.getImage("assets/title.png");
		var title_texture = title_asset.tilesheet_from_image(core.screen.display_shutter.width, core.screen.display_shutter.height);
		var sprites = new Tiles(core.screen.display_shutter, title_texture, "title", core.screen.display_shutter.width, 1);
		sprites.make(0, 0, core.screen.display_shutter.width, core.screen.display_shutter.height, 0, false);

		var glyph_width = 16;
		var glyphs = new Glyphs(core.screen.display_shutter, {
			element_width: glyph_width,
			element_height: 16,
			tile_width: glyph_width,
			tile_height: 16,
			tile_asset_path: "assets/font-shuriken-16x16.png",
		});

		var message_text = "Click me!";
		var message_width_px = message_text.length * glyph_width;
		var message_x = core.screen.display_shutter.width / 2 - (message_width_px / 2);
		var message_y = 300;

		message = glyphs.make_line(message_x, message_y, message_text, message_color);

		hot_spot = new HotSpot(0, 0, core.screen.display_shutter.width, core.screen.display_shutter.height);
		hot_spot.on_press = button ->
		{
			trace('shutter clicked');
			open_shutter(15, null);
		}
		core.screen.display_shutter.add(hot_spot);
	}

	public function update()
	{
		if (is_opening || is_closing)
		{
			core.screen.display_shutter.yOffset = -Std.int(core.screen.display_shutter.height * ease.step(1));
		}

		if (is_closed)
		{
			trace('set shutter control');
			core.input.change_target(controller);
		}

		if (is_opening && ease.is_at_end())
		{
			core.screen.display_shutter.hide();
			is_open = true;
			is_opening = false;
			is_closed = false;
			is_closing = false;

			if (on_open_complete != null)
			{
				on_open_complete();
				on_open_complete = null;
			}
		}

		if (is_closing && ease.is_at_end())
		{
			is_closed = true;
			is_closing = false;
			is_open = false;
			is_opening = false;
			trace('shutter closed, it is taking input now');
			core.input.change_target(controller);
			if (on_close_complete != null)
			{
				on_close_complete();
				on_close_complete = null;
			}
		}
	}

	public function change_scene_controller(controller: ControllerActions)
	{
		scene_controller = controller;
	}

	public function open_shutter(duration: Int = 20, on_complete: Void -> Void)
	{
		if (!is_closed)
		{
			return;
		}
		is_opening = true;
		core.screen.display_shutter.show();

		message.change_tint(0x00000000);
		ease.configure(0.0, 1.0, duration);
		if (on_complete != null)
		{
			on_open_complete = on_complete;
		}
	}

	public function close_shutter(duration: Int = 10, on_complete: Void -> Void)
	{
		if (!is_open)
		{
			return;
		}
		is_closing = true;

		ease.configure(1.0, 0.0, duration);
		if (on_complete != null)
		{
			on_close_complete = on_complete;
		}
	}
}
