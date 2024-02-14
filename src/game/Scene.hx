package game;

import game.HudMenu;
import input2action.Input2Action;
import lib.input2action.Controller;
import lib.lime.Audio;
import lib.pure.Loop;
import lime.ui.Window;

using lib.peote.TextureTools;

@:publicFields
abstract class Scene
{
	var input2Action: Input2Action;
	var core: GameCore;
	var controller: ControllerActions;
	var menu: HudMenu;
	var menu_config: MenuConfig;
	var is_update_enabled: Bool = false;

	public function new(core: GameCore, menu_config: MenuConfig)
	{
		this.core = core;
		this.menu_config = menu_config;

		controller = {
			select: {
				on_press: () ->
				{
					if (!menu.is_open)
					{
						menu_open();
					}
					else
					{
						menu_close();
					}
				},
			}
		}
	}

	function menu_open()
	{
		menu.open(controller);
		core.pause();
	}

	function menu_close()
	{
		menu.close();
		core.unpause();
	}

	public function init()
	{
		if (menu != null && menu.is_open)
		{
			menu.close();
			menu.dispose();
			menu = null;
		}

		menu = new HudMenu(core, menu_config);

		begin();
	}

	/**
		Handle scene set up here, e.g. set up level, player, etc.
	**/
	abstract public function begin(): Void;

	/**
		Handle loop logic here, e,g, calculating movement for player, change object states, etc.
	**/
	abstract public function update(): Void;

	/**
		Make draw calls here
		@param step_ratio is the ratio of one whole game step has passed since the last step, between 0 and 1 (see Loop)
	**/
	abstract public function draw(step_ratio: Float): Void;

	/**
		Clean up the scene here, e.g. remove elements from graphics buffers
	**/
	abstract public function end(): Void;

	public function dispose_menu()
	{
		menu.dispose();
	}

	public function input_enable()
	{
		core.input.change_target(controller);
	}
}

@:publicFields
class GameCore
{
	var screen(default, null): Screen;
	var input(default, null): Input;
	var sound: SoundManager;
	var fixed_steps_per_second(default, null) = 30;
	var loop(default, null): Loop;
	var scene(default, null): Scene;
	private var is_paused: Bool = false;
	var shutter: Shutter;

	function new(window: Window, screen: Screen, sound: SoundManager, scene_constructor: GameCore -> Scene)
	{
		input = new Input(window);

		this.screen = screen;
		this.sound = sound;
		shutter = new Shutter(this);

		loop = new Loop({
			step: () -> fixed_step_update(),
			end: step_ratio -> draw(step_ratio),
		}, fixed_steps_per_second);

		var is_shutter_staying_closed = true;
		scene_begin(scene_constructor, is_shutter_staying_closed);
	}

	private function scene_begin(scene_constructor: GameCore -> Scene, is_shutter_staying_closed: Bool = false)
	{
		scene = scene_constructor(this);
		if (is_shutter_staying_closed)
		{
			scene.init();
		}
		else
		{
			shutter.open_shutter(() -> scene.init());
		}
	}

	private inline function scene_end()
	{
		if (scene != null)
		{
			scene.dispose_menu();
			scene.end();
		}
	}

	function scene_change(scene_constructor: GameCore -> Scene)
	{
		trace('change scene');
		scene_end();
		screen.display_hud_show();
		shutter.close_shutter(() -> scene_begin(scene_constructor));
	}

	function scene_reset()
	{
		if (scene != null)
		{
			is_paused = false;
			scene.end();
			scene.init();
		}
	}

	private function fixed_step_update()
	{
		shutter.update();
		if (scene.is_update_enabled)
		{
			scene.update();
		}
	}

	private function draw(step_ratio: Float)
	{
		if (scene.is_update_enabled)
		{
			scene.draw(step_ratio);
		}
	}

	function frame(elapsed_ms: Int)
	{
		if (!is_paused)
		{
			loop.frame(elapsed_ms);
		}
		else
			trace('core is paused, not running loop');
	}

	public function pause()
	{
		is_paused = true;
	}

	public function unpause()
	{
		is_paused = false;
	}
}
