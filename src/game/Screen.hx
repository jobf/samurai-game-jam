package game;

import lime.utils.Assets;
import lib.peote.Elements;
import lib.peote.FramebufferTextureSlots;
import peote.view.Display;
import peote.view.PeoteView;


@:publicFields
class Screen
{
	var display_width: Int;
	var display_height: Int;
	var window_width: Int;
	var window_height: Int;

	var peote_view: PeoteView;

	var display_bg: Display;
	var display_level_behind: Display;
	var display_entities: Display;
	var display_icons: Display;
	var display_level_in_front: Display;
	var display_hud: Display;
	var display_shutter: Display;

	var element_shutter: ViewElement;
	var view_display: Display;
	var element_bg: ViewElement;
	var element_hud: ViewElement;

	var res_width = 530;
	var res_height = 400;
	var slot: Int = 0;
	var render_textures: FramebufferTextureSlots;

	public function new(peote_view: PeoteView)
	{
		slot = 0;
		this.peote_view = peote_view;
		display_width = this.peote_view.width;
		display_height = this.peote_view.height;
		window_width = this.peote_view.width;
		window_height = this.peote_view.height;

		var slot_count = 8;

		var display_colors: Array<Int> = [
			0x243d5cFF, // bg
			0x00000000, // level behind
			0x00000000, // level entities
			0x00000000, // level icons
			0x00000000, // level in front
			0x5c8b93FF, // hud
			0x00000000, //
			0x243d5c10, // shutter
		];

		render_textures = new FramebufferTextureSlots(peote_view, window_width, window_height, slot_count, display_colors);

		view_display = new Display(0, 0, window_width, window_height);

		peote_view.addDisplay(view_display);

		render_textures.add_to_display(view_display);

		display_bg = render_textures.displays[0].display;
		element_bg = render_textures.displays[0].element;

		display_level_behind = render_textures.displays[1].display;
		display_entities = render_textures.displays[2].display;
		display_icons = render_textures.displays[3].display;
		display_level_in_front = render_textures.displays[4].display;

		display_hud = render_textures.displays[5].display;
		element_hud = render_textures.displays[5].element;

		// render_textures.displays[6].display;

		display_shutter = render_textures.displays[7].display;
		element_shutter = render_textures.displays[7].element;

		display_hud.zoom = 2;
		display_hud_hide();


		fit_to_window();

		peote_view.window.onResize.add((width, height) ->
		{
			this.window_width = width;
			this.window_height = height;
			fit_to_window();
		});
	}

	function display_hud_hide()
	{
		element_hud.tint.a = 0x00;
		draw();
	}

	function display_hud_show()
	{
		element_hud.tint.a = 0xff;
		draw();
	}

	function display_shutter_hide()
	{
		element_shutter.tint.a = 0x00;
		draw();
	}

	function display_shutter_show()
	{
		element_shutter.tint.a = 0xff;
		draw();
	}

	function fit_to_window()
	{
		var scale = 1.0;

		if (display_height < display_width)
		{
			// use height to determine scale when height is smaller edge
			scale = window_height / res_height;
		}
		else
		{
			// use width to determine scale when width is smaller edge
			scale = window_width / res_width;
		}

		// keep scale is noit less than 1
		if (scale < 1)
		{
			scale = 1;
		}

		// ensure up-scaling is an even number
		if (scale > 2 && scale % 2 != 0)
		{
			scale -= 1;
		}

		// scale all of peote-view (then every display is scaled together)
		peote_view.zoom = scale;

		// offset the view display to keep it in the center of the window
		var view_x = Std.int(((peote_view.width / scale) / 2) - (res_width / 2));
		var view_y = Std.int(((peote_view.height / scale) / 2) - (res_height / 2));
		view_display.x = view_x;
		view_display.y = view_y;
		// trace('scaled $scale x y $view_x $view_y');
	}

	public function draw()
	{
		render_textures.view_buffer.update();
	}
}
/*
	#2b2821
	#624c3c
	#d9ac8b
	#e3cfb4
	#243d5c
	#5d7275
	#5c8b93
	#b1a58d
	#b03a48
	#d4804d
	#e0c872
	#3e6958
 */
