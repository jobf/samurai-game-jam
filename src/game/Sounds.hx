package game;

import lib.lime.Audio;

@:enum
abstract SoundKey(Int) from Int to Int
{
	var BUTTON = 0;
	var BEGIN = 1;
	var WIN = 2;
	var HURT_A = 3;
	var HURT_B = 4;
	var DIE = 5;
	var SWIPE = 6;
	var COLLECT = 7;
}

function init_sound_effects(): SoundManager
{
	var sound_manager = new SoundManager();

	sound_manager.load_sound_assets([
		BUTTON => "assets/fx_button.ogg",
		BEGIN => "assets/fx_begin.ogg",
		WIN => "assets/fx_win.ogg",
		HURT_A => "assets/fx_hurt_a.ogg",
		HURT_B => "assets/fx_hurt_b.ogg",
		DIE => "assets/fx_die.ogg",
		SWIPE => "assets/fx_swipe.ogg",
		COLLECT => "assets/fx_collect.ogg",
	]);

	return sound_manager;
}
