package game.scenes;

import game.HudMenu;
import game.Scene;
import game.Sounds;

class Options extends Scene
{
	public function new(core: GameCore)
	{
		var menu: MenuConfig = {
			introduction: [],
			items: [
				{
					label: "VOLUME DOWN",
					action: () ->
					{
						core.sound.reduce_gain();
						core.sound.play_sound(SoundKey.HURT_B);
					},
				},
				{
					label: "VOLUME UP",
					action: () ->
					{
						core.sound.increase_gain();
						core.sound.play_sound(SoundKey.HURT_B);
					}
				},
				{
					label: "BACK",
					action: () -> core.scene_change(core -> new Title(core)),
				}
			]
		}
		super(core, menu);
	}

	public function begin()
	{
		menu_open();
		core.unpause();
	}

	public function update() {}

	public function draw(step_ratio: Float) {}

	public function end() {}
}
