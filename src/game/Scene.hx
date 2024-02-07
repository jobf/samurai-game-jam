package game;

import game.HudMenu;
import input2action.Input2Action;
import lib.input2action.Controller;
import lib.lime.Audio;
import lib.pure.Ease;
import lib.pure.Loop;
import lib.pure.Repeat;
import lib.pure.Transformation;
import lime.ui.Window;

using lib.peote.TextureTools;

abstract class Scene
{
	var input2Action: Input2Action;
	var core: GameCore;
	var controller: ControllerActions;
	var menu: HudMenu;
	var menu_config: MenuConfig;
	var shutter_ease: Ease;
	var shutter: Repeat;
	var shutter_is_closing: Bool;
	var shutter_is_closed: Bool;
	var shutter_is_opening: Bool;
	var shutter_is_open: Bool;

	public function new(core: GameCore, menu_config: MenuConfig)
	{
		this.core = core;
		this.menu_config = menu_config;

		shutter_ease = new Ease(0.0, 1.0, 25, smooth_start_2);
		shutter = {
			duration: 0,
			action: repeat -> transition_shutter(repeat)
		}
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

	function transition_shutter(repeat: Repeat)
	{
		core.screen.display_shutter.yOffset = -Std.int(core.screen.element_shutter.height * shutter_ease.step(1));

		if (shutter_ease.is_at_end())
		{
			if (shutter_is_opening)
			{
				shutter_is_open = true;
				shutter_is_opening = false;
			}
			if (shutter_is_closing)
			{
				shutter_is_closed = true;
				shutter_is_closing = false;
			}
		}
	}

	public function open_shutter(duration: Int = 30)
	{
		shutter_is_opening = true;
		shutter_ease.configure(0.0, 1.0, duration);
	}

	public function close_shutter(duration: Int = 30)
	{
		shutter_is_closing = true;
		shutter_ease.configure(1.0, 0.0, duration);
	}

	function menu_open()
	{
		menu.open(core.input, controller);
		core.is_paused = true;
	}

	function menu_close()
	{
		menu.close();
		core.is_paused = false;
	}

	public function init()
	{
		if (menu != null && menu.is_open)
		{
			menu.close();
			menu.dispose();
			menu = null;
		}

		menu = new HudMenu(core.screen, menu_config, core.sound);

		begin();
	}

	/**
		Handle scene set up here, e.g. set up level, player, etc.
	**/
	abstract public function begin(): Void;

	/**
		Handle loop logic here, e,g, calculating movement for player, change object states, etc.
	**/
	public function update()
	{
		shutter.update();
	}

	/**
		Make draw calls here
		@param step_ratio is the ratio of one whole game step has passed since the last step, between 0 and 1 (see Loop)
	**/
	abstract public function draw(step_ratio: Float): Void;

	/**
		Clean up the scene here, e.g. remove elements from graphics buffers
	**/
	abstract public function end(): Void;

	function change(scene_constructor: GameCore -> Scene)
	{
		menu_close();
		core.scene_change(scene_constructor);
	}

	public function dispose_menu()
	{
		menu.dispose();
	}

	public function input_enable()
	{
		core.input.change_target(controller);
	}

	public function pause()
	{
		menu_open();
	}

	public function unpause()
	{
		menu_close();
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
	var is_paused: Bool = false;

	function new(window: Window, screen: Screen, sound: SoundManager, scene_constructor: GameCore -> Scene)
	{
		input = new Input(window);

		this.screen = screen;
		this.sound = sound;

		loop = new Loop({
			step: () -> fixed_step_update(),
			end: step_ratio -> draw(step_ratio),
		}, fixed_steps_per_second);

		scene_begin(scene_constructor);
	}

	private function scene_begin(scene_constructor: GameCore -> Scene)
	{
		scene = scene_constructor(this);
		scene.input_enable();
		scene.init();
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
		scene_end();

		scene_begin(scene_constructor);
	}

	function scene_reset()
	{
		if (scene != null)
		{
			is_paused = false;
			scene.end();
			scene.init();
			scene.input_enable();
		}
	}

	private function fixed_step_update()
	{
		scene.update();
	}

	private function draw(step_ratio: Float)
	{
		scene.draw(step_ratio);
	}

	function frame(elapsed_ms: Int)
	{
		if (!is_paused)
		{
			loop.frame(elapsed_ms);
		}
	}

	public function pause()
	{
		is_paused = true;
		scene.pause();
	}

	public function unpause()
	{
		is_paused = false;
		scene.unpause();
	}
}
