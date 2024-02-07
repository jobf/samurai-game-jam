package lib.peote;

import peote.view.Buffer;
import peote.view.Color;
import peote.view.Display;
import peote.view.Element;
import peote.view.PeoteView;
import peote.view.Program;
import peote.view.Texture;

class ViewElement implements Element
{
	@posX public var x: Int;
	@posY public var y: Int;
	@sizeX public var width: Int;
	@sizeY public var height: Int;
	@texSlot("view") public var slot: Int;
	@color public var tint: Color = 0xffffffFF;

	public function new(x: Int, y: Int, width: Int, height: Int, slot: Int)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.slot = slot;
	}
}

@:structInit
@:publicFields
class DisplayElement
{
	var display: Display;
	var element: ViewElement;
}

@:publicFields
class FramebufferTextureSlots
{
	var texture: Texture;
	var displays: Array<DisplayElement>;
	var view_program: Program;
	var view_buffer: Buffer<ViewElement>;

	function new(peote_view: PeoteView, width: Int, height: Int, slot_count: Int, display_colors: Array<Int>)
	{
		if (display_colors.length != slot_count)
		{
			throw "display colors array length must equal slot count";
		}

		texture = new Texture(width, height, slot_count);

		view_buffer = new Buffer<ViewElement>(slot_count);
		view_program = new Program(view_buffer);
		view_program.blendEnabled = true;
		view_program.addTexture(texture, "view", true);

		displays = [
			for (slot in 0...slot_count)
			{
				var display = new Display(
					0,
					0,
					width,
					height,
					display_colors[slot]
				);
				peote_view.addFramebufferDisplay(display);

				var element = new ViewElement(0, 0, width, height, slot);
				view_buffer.addElement(element);

				display.setFramebuffer(texture, slot, peote_view);
				{
					display: display,
					element: element
				}
			}
		];
	}

	function add_to_display(display: Display)
	{
		view_program.addToDisplay(display);
	}
}
