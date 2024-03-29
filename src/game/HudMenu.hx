package game;

import game.Scene.GameCore;
import lib.input2action.Controller;
import lib.peote.Glyph;
import lib.peote.Mouse.HotSpot;
import lib.pure.Menu;
import lib.pure.Node;
import lime.ui.MouseButton;
import lime.ui.Window;

class HudMenu
{
	var menu: Menu;
	var controller: ControllerActions;
	var core: GameCore;
	var glyphs: Glyphs;
	var glyph_color_idle = 0x243d5cFF;
	var glyph_color_selected = 0xe0c872ff;

	var buttons: Array<Button>;
	var window: Window;

	public var is_open: Bool = false;

	var previous_controller: ControllerActions;
	var on_close: Void -> Void;

	public function new(core: GameCore, menu_config: MenuConfig)
	{
		this.core = core;
		core.screen.display_hud_hide();
		this.on_close = menu_config.on_close;
		var gap = 4;
		var line_height = 20;
		var x: Float = 10;
		var y: Float = 10;

		if (menu_config.is_aligned_to_bottom)
		{
			y = (core.screen.display_hud.height / core.screen.display_hud.zoom) - line_height;
			trace('hud menu start $y');
			line_height *= -1;
		}

		var font: FontModel = {
			element_width: 16,
			element_height: 16,
			tile_width: 16,
			tile_height: 16,
			tile_asset_path: "assets/font-shuriken-16x16.png",
		}
		glyphs = new Glyphs(core.screen.display_hud, font);

		menu = new Menu(menu_config.items, on_navigate);

		buttons = [];
		var line_height = font.element_height + gap;

		var button_creator: NodeVisitor<MenuItem> = {
			visit: (node, depth) ->
			{
				var button = new Button(glyphs.make_line(x, y, node.item.label, glyph_color_idle), {
					on_press: (button, mouse_button) ->
					{
						node.item.action();
					},
					// on_release: on_release,
					on_over: button ->
					{
						button.label.change_tint(glyph_color_selected);
						menu.change_selection(node.item);
					},
					// on_out: button -> button.label.change_tint(glyph_color_idle),
					x: x,
					y: y,
					width: font.element_width * node.item.label.length,
					height: font.element_height
				});

				buttons.push(button);
				y += line_height;
				core.screen.display_hud.add(button.interactive);
				button;
			}
		}

		menu.recurse_with(button_creator);

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
					menu.iterate_selection(-1);
				},
			},
			down: {
				on_press: () -> menu.iterate_selection(1),
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

		is_open = true;
		close();
	}

	function on_navigate(): Void
	{
		for (button in buttons)
		{
			if (menu.selected_label() == button.label.text)
			{
				button.label.change_tint(glyph_color_selected);
			}
			else
			{
				button.label.change_tint(glyph_color_idle);
			}
		}
	}

	public function open(previous_controller: ControllerActions)
	{
		if (!is_open)
		{
			trace('open hud');
			is_open = true;
			core.screen.display_hud_show();

			// remember previous controller
			this.previous_controller = previous_controller;

			// target HUD controller
			core.input.change_target(controller);
		}
	}

	public function close()
	{
		if (is_open)
		{
			trace('close hud');
			is_open = false;
			core.screen.display_hud_hide();

			if (previous_controller != null)
			{
				// target previouis controller
				core.input.change_target(previous_controller);
			}
			on_close();
		}
	}

	public function dispose()
	{
		glyphs.clear();
		for (button in buttons)
		{
			core.screen.display_hud.remove(button.interactive);
		}
	}
}

@:publicFields
@:structInit
class MenuConfig
{
	var introduction: Array<String>;
	var items: Array<MenuItemConfig>;
	var is_aligned_to_bottom: Bool = false;
	var on_close: Void -> Void = () -> return;
}

@:publicFields
class Button
{
	var label: GlyphLine;
	var config: ButtonConfig;
	var interactive: HotSpot;
	var glyph_color_out = 0x243d5cFF;
	var glyph_color_over = 0x243d5cFF;
	var glyph_color_selected = 0xe0c872ff;

	public function new(label: GlyphLine, config: ButtonConfig)
	{
		this.label = label;
		this.config = config;
		interactive = new HotSpot(config.x, config.y, config.width, config.height);
		interactive.on_out = () -> config.on_out(this);
		interactive.on_over = () -> config.on_over(this);
		interactive.on_press = mouse_button -> config.on_press(this, mouse_button);
		interactive.on_release = mouse_button -> config.on_release(this, mouse_button);
	}
}

@:publicFields
@:structInit
class ButtonConfig
{
	var on_press: (button: Button, mouse_button: MouseButton) -> Void = (button, mouse_button) -> return;
	var on_release: (Button, MouseButton) -> Void = (button, mouse_button) -> return;
	var on_over: Button -> Void = Button -> return;
	var on_out: Button -> Void = Button -> return;
	var x: Float;
	var y: Float;
	var width: Float;
	var height: Float;
}
