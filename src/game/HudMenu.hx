package game;

import lib.input2action.Controller;
import lib.lime.Audio;
import lime.ui.Window;
import peote.view.Display;
import lib.peote.Glyph;
import lib.pure.Menu;
import lib.pure.Node;

class HudMenu
{
	var display_hud: Display;
	var menu: Menu;
	var controller: ControllerActions;

	var glyphs: Glyphs;
	var glyph_color_idle = 0x243d5cFF;
	var glyph_color_selected = 0xe0c872ff;

	var lines: Array<GlyphLine> = [];
	var window: Window;
	var screen: Screen;

	public var is_open: Bool = false;

	public function new(screen: Screen, menu_config: MenuConfig, sound: SoundManager)
	{
		this.screen = screen;
		this.display_hud = screen.display_hud;

		var x = 0;
		var y = 10;
		var line_height = 20;

		glyphs = new Glyphs(display_hud, {
			element_width: 16,
			element_height: 16,
			tile_width: 16,
			tile_height: 16,
			tile_asset_path: "assets/font-shuriken-16x16.png",
		});

		var on_action = () -> return;
		menu = new Menu(menu_config.items, on_navigate, on_action);
		for (text in menu_config.introduction)
		{
			glyphs.make_line(x, y, text, glyph_color_idle);
			y += line_height;
		}

		var label_creator: NodeVisitor<MenuItem> = {
			visit: (node, depth) ->
			{
				lines.push(glyphs.make_line(x, y, node.item.label, glyph_color_idle));
				y += line_height;
			}
		}

		menu.recurse_with(label_creator);

		controller = {
			left: {
				on_press: () -> menu.ascend(),
			},
			right: {
				on_press: () -> menu.descend(),
			},
			up: {
				on_press: () ->
				{
					menu.change_selection(-1);
				},
			},
			down: {
				on_press: () -> menu.change_selection(1),
			},
			a: {
				on_press: () -> menu.perform_selected_action(),
			},
			b: {
				on_press: () -> menu.perform_selected_action(),
			},
			start: {
				on_press: () -> menu.perform_selected_action(),
			},
			select: {
				on_press: () -> close(),
			}
		}

		on_navigate();
	}

	function on_navigate()
	{
		for (line in lines)
		{
			if (menu.selected_label() == line.text)
			{
				line.change_tint(glyph_color_selected);
			}
			else
			{
				line.change_tint(glyph_color_idle);
			}
		}
	};

	var give_control_to_scene: () -> Void;

	public function open(input: Input, previous_controller: ControllerActions)
	{
		is_open = true;

		give_control_to_scene = () -> input.change_target(previous_controller);
		input.change_target(controller);

		screen.display_hud_show();
	}

	public function close()
	{
		if (is_open)
		{
			is_open = false;

			screen.display_hud_hide();

			give_control_to_scene();
		}
	}

	public function dispose()
	{
		glyphs.clear_all();
	}
}

@:publicFields
@:structInit
class MenuConfig
{
	var introduction: Array<String>;
	var items: Array<MenuItemConfig>;
}
