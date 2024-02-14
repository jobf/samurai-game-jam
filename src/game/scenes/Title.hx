package game.scenes;

import lib.peote.Glyph;
import game.HudMenu;
import game.Scene;
import game.Sounds;

class Title extends Scene
{
	public function new(core: GameCore)
	{
		var menu: MenuConfig = {
			introduction: [],
			items: [
				{
					label: "START",
					action: () ->
					{
						core.sound.play_sound(SoundKey.BUTTON);
						core.scene_change(core -> new Intro(core));
					},
				},
				{
					label: "OPTIONS",
					action: () -> core.scene_change(core -> new Options(core)),
				}
			],
			
		}
		super(core, menu);
	}

	public function begin()
	{
		@:privateAccess
		core.shutter.on_open_complete = () ->
		{
			// pass control to the menu after shutter is opened
			core.input.change_target(core.scene.menu.controller);
		}

		menu_open();
		core.unpause();
	}

	public function update() {}

	public function draw(step_ratio: Float) {}

	public function end() {}
}

class Intro extends Scene
{
	var pager: Pager;

	public function new(core: GameCore)
	{
		var menu: MenuConfig = {
			introduction: [],
			items: [
				{
					label: "OK",
					action: () ->
					{
						core.sound.play_sound(SoundKey.BUTTON);
						if (pager.is_on_last_page())
						{
							// start level if we've seen all pages
							core.scene_change(core -> new Play(core));
						}
						else
						{
							pager.show_next_page();
						}
					},
				}
			],
			is_aligned_to_bottom: true,
			
		}

		super(core, menu);
	}

	public function begin()
	{
		pager = new Pager(
			[
				"The sacred stone is missing ...",
				"A curse falls upon the shrine",
				"Only YOU can retrieve the stone and restore balance ...",
			],
			core.screen.display_hud,
			{
				element_width: 16,
				element_height: 16,
				tile_width: 16,
				tile_height: 16,
				tile_asset_path: "assets/font-shuriken-16x16.png",
			},
			core.screen.display_hud.width / 2,
			core.screen.display_hud.height / 2,
			20
		);

		trace('begin Intro');
		menu_open();
		core.unpause();
	}

	public function update() {}

	public function draw(step_ratio: Float) {}

	public function end()
	{
		pager.clear();
	}
}

class End extends Scene
{
	var pager: Pager;

	public function new(core: GameCore)
	{
		var menu: MenuConfig = {
			introduction: [],
			items: [
				{
					label: "OK",
					action: () ->
					{
						core.sound.play_sound(SoundKey.BUTTON);
						if (pager.is_on_last_page())
						{
							core.scene_change(core -> new Title(core));
						}
						else
						{
							pager.show_next_page();
						}
					},
				}
			],
			is_aligned_to_bottom: true,
			
		}

		super(core, menu);
	}

	public function begin()
	{
		pager = new Pager(
			["The sacred stone was returned ...", "and balance restored !",],
			core.screen.display_hud,
			{
				element_width: 16,
				element_height: 16,
				tile_width: 16,
				tile_height: 16,
				tile_asset_path: "assets/font-shuriken-16x16.png",
			},
			core.screen.display_hud.width / 2,
			core.screen.display_hud.height / 2,
			20
		);

		trace('begin End');
		menu_open();
		core.unpause();
	}

	public function update() {}

	public function draw(step_ratio: Float) {}

	public function end()
	{
		pager.clear();
	}
}
