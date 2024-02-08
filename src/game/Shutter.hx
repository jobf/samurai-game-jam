package game;

import lib.peote.Elements;
import lib.pure.Ease;
import lib.pure.Transformation;
import lime.utils.Assets;
import peote.view.Display;

using lib.peote.TextureTools;

class Shutter
{
	var display: Display;
	var ease: Ease;
	public var is_closing(default, null): Bool;
	public var is_closed(default, null): Bool;
	public var is_opening(default, null): Bool;
	public var is_open(default, null): Bool;

	public function new(display: Display)
	{
		this.display = display;
		ease = new Ease(0.0, 1.0, 25, smooth_start_2);

		var title_asset = Assets.getImage("assets/title.png");
		var title_texture = title_asset.tilesheet_from_image(display.width, display.height);
		var sprites = new Tiles(display, title_texture, "title", 530, 1);
		sprites.make(0, 0, display.width, display.height, 0, false);
	}

	public function update()
	{
		display.yOffset = -Std.int(display.height * ease.step(1));

		if (ease.is_at_end())
		{
			if (is_opening)
			{
				is_open = true;
				is_opening = false;
			}
			if (is_closing)
			{
				is_closed = true;
				is_closing = false;
			}
		}
	}

	public function open_shutter(duration: Int = 30)
	{
		is_opening = true;
		ease.configure(0.0, 1.0, duration);
	}

	public function close_shutter(duration: Int = 30)
	{
		is_closing = true;
		ease.configure(1.0, 0.0, duration);
	}
}
