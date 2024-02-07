package lib.peote;

import lib.peote.Elements;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Display;
import peote.view.PeoteView;
import peote.view.Program;

class PreloaderUi
{
	var progress_bar: Fill;
	var buffer: Buffer<Fill>;
	var bar_complete_width: Float;
	var bar_complete_height: Float;
	var display: Display;
	var peote_view: PeoteView;

	public function new(peote_view: PeoteView)
	{
		this.peote_view = peote_view;
		display = new Display(0, 0, peote_view.width, peote_view.height, 0x243d5cff);
		peote_view.addDisplay(display);

		buffer = new Buffer<Fill>(1);
		var program = new Program(buffer);
		display.addProgram(program);

		var bar_color = Color.MAGENTA;
		bar_complete_width = peote_view.width;
		bar_complete_height = peote_view.height;
		var bar_height = 32;

		progress_bar = new Fill(0, 0, 0, 0, bar_color, false);
		buffer.addElement(progress_bar);
	}

	public function onPreloadProgress(loaded: Int, total: Int)
	{
		progress_bar.height = Std.int(bar_complete_width * (loaded / total));
		buffer.updateElement(progress_bar);
	}

	public function clear()
	{
		buffer.clear(true, true);
		peote_view.removeDisplay(display);
	}
}
