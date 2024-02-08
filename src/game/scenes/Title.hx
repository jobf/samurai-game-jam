package game.scenes;

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
						// core.screen.display_shutter_hide();
						core.sound.play_sound(SoundKey.BUTTON);
						change(core -> new StoryA(core));
					},
				},
				{
					label: "OPTIONS",
					action: () -> change(core -> new Options(core)),
				}
			]
		}
		super(core, menu);
	}

	public function begin()
	{
		menu_open();
		core.is_paused = false;
		core.screen.draw();
	}

	override function update()
	{
		super.update();
	}

	public function draw(step_ratio: Float) {}

	public function end() {}
}

class StoryA extends Scene
{
	public function new(core: GameCore)
	{
		var menu: MenuConfig = {
			introduction: ["The sacred", "stone is", "missing...",],
			items: [
				{
					label: "OK",
					action: () ->
					{
						core.sound.play_sound(SoundKey.BUTTON);
						change(core -> new StoryB(core));
					},
				}
			]
		}

		super(core, menu);
	}

	public function begin()
	{
		menu_open();
		core.is_paused = false;
	}

	override function update()
	{
		super.update();
	}

	public function draw(step_ratio: Float) {}

	public function end() {}
}

class StoryB extends Scene
{
	public function new(core: GameCore)
	{
		var menu: MenuConfig = {
			introduction: ["A curse falls", "upon the", "shrine"],
			items: [
				{
					label: "OK",
					action: () ->
					{
						core.sound.play_sound(SoundKey.BUTTON);
						change(core -> new StoryC(core));
					},
				}
			]
		}

		super(core, menu);
	}

	public function begin()
	{
		menu_open();
		core.is_paused = false;
	}

	override function update()
	{
		super.update();
	}

	public function draw(step_ratio: Float) {}

	public function end() {}
}

class StoryC extends Scene
{
	public function new(core: GameCore)
	{
		var menu: MenuConfig = {
			introduction: ["Only YOU can", "retrieve the", "stone", "and restore", "balance..."],
			items: [
				{
					label: "OK",
					action: () ->
					{
						core.screen.display_shutter_show();
						change(core -> new Play(core));
					},
				}
			]
		}

		super(core, menu);
	}

	public function begin()
	{
		menu_open();
		core.is_paused = false;
	}

	override function update()
	{
		super.update();
	}

	public function draw(step_ratio: Float) {}

	public function end() {}
}

class End extends Scene
{
	public function new(core: GameCore)
	{
		var menu: MenuConfig = {
			introduction: ["The stone was", "returned", "and", "balance", "restored"],
			items: [
				{
					label: "OK",
					action: () ->
					{
						core.screen.display_shutter_show();
						change(core -> new Title(core));
					},
				}
			]
		}

		super(core, menu);
	}

	public function begin()
	{
		menu_open();
		core.is_paused = false;
	}

	override function update()
	{
		super.update();
	}

	public function draw(step_ratio: Float) {}

	public function end() {}
}
