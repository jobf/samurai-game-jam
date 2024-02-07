import game.Scene;
import game.scenes.Title;
import game.Screen;
import game.Sounds;
import haxe.CallStack;
import haxe.Log;
import lib.peote.PreloaderUi;
import lime.app.Application;
import lime.ui.KeyCode;
import peote.view.PeoteView;

class Main extends Application
{
	var peote_view: PeoteView;
	var preloader_ui: PreloaderUi;
	var is_ready: Bool;

	var core: GameCore;
	var last_trace: Dynamic;

	override function onWindowCreate(): Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try
				{
					is_ready = false;

					var background_color = 0x5d7275FF;
					// var background_color = 0xf000f0ff;
					peote_view = new PeoteView(window, background_color);
					preloader_ui = new PreloaderUi(peote_view);
				} catch (_)
				{
					trace(CallStack.toString(CallStack.exceptionStack()), _);
				}
			default:
				throw("It appears you are running without OpenGL, this is impressive but sorry it won't work!");
		}
		var trace_original = Log.trace;
		Log.trace = (v, ?infos) ->
		{
			if (last_trace != v)
			{
				trace_original(v, infos);
				last_trace = v;
			}
		}
	}

	override function onPreloadProgress(loaded: Int, total: Int)
	{
		if (preloader_ui != null)
		{
			preloader_ui.onPreloadProgress(loaded, total);
		}
	}

	override function onPreloadComplete(): Void
	{
		preloader_ui.clear();

		var screen = new Screen(peote_view);
		var sound = init_sound_effects();

		core = new GameCore(
			window,
			screen,
			sound,
			core -> new Title(core)
		);

		// core = new GameCore(window, screen, sound, core -> new Play(core));

		is_ready = true;
	}

	override function update(deltaTime: Int): Void
	{
		if (is_ready)
		{
			core.frame(deltaTime);
		}
	}

	override function onKeyDown(keyCode: lime.ui.KeyCode, modifier: lime.ui.KeyModifier): Void
	{
		if (!is_ready)
			return;

		#if !web
		if (keyCode == ESCAPE)
		{
			window.close();
		}
		#end
	}
}
