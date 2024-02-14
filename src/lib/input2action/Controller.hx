package lib.input2action;

import input2action.GamepadAction;
import input2action.KeyboardAction;
import input2action.ActionConfig;
import input2action.ActionMap;
import input2action.Input2Action;
import lime.ui.Gamepad;
import lime.ui.GamepadButton;
import lime.ui.KeyCode;
import lime.ui.Window;

@:publicFields
class Controller
{
	static function init_action_config(): ActionConfig
	{
		return [
			{
				gamepad: GamepadButton.DPAD_LEFT,
				keyboard: [KeyCode.LEFT, KeyCode.A],
				action: "left"
			},
			{
				gamepad: GamepadButton.DPAD_RIGHT,
				keyboard: [KeyCode.RIGHT, KeyCode.D],
				action: "right"
			},
			{
				gamepad: GamepadButton.DPAD_UP,
				keyboard: [KeyCode.UP, KeyCode.W],
				action: "up"
			},
			{
				gamepad: GamepadButton.DPAD_DOWN,
				keyboard: [KeyCode.DOWN, KeyCode.S],
				action: "down"
			},
			{
				gamepad: GamepadButton.B,
				keyboard: KeyCode.H,
				action: "b"
			},
			{
				gamepad: GamepadButton.A,
				keyboard: [KeyCode.G],
				action: "a"
			},
			{
				gamepad: GamepadButton.START,
				keyboard: [KeyCode.RETURN, KeyCode.RETURN2, KeyCode.NUMPAD_ENTER],
				action: "start"
			},
			{
				gamepad: GamepadButton.BACK,
				keyboard: [KeyCode.BACKSPACE],
				action: "select"
			},
		];
	}
}

@:structInit
@:publicFields
class ControllerActions
{
	var left: ButtonAction = {};
	var right: ButtonAction = {};
	var up: ButtonAction = {};
	var down: ButtonAction = {};
	var a: ButtonAction = {};
	var b: ButtonAction = {};
	var start: ButtonAction = {};
	var select: ButtonAction = {};

	public function clone(): ControllerActions
	{
		return {
			left: left,
			right: right,
			up: up,
			down: down,
			a: a,
			b: b,
			start: start,
			select: select
		}
	}
}

@:structInit
@:publicFields
class ButtonAction
{
	var on_press: Void -> Void = () -> return;
	var on_release: Void -> Void = () -> return;
}

class Input
{
	var input2Action: Input2Action;
	var target: ControllerActions;

	public function new(window: Window)
	{
		target = {}

		var action_map: ActionMap = [
			"left" => {
				action: (isDown, player) ->
				{
					if (isDown)
						target.left.on_press();
					else
						target.left.on_release();
				},
				up: true
			},
			"right" => {
				action: (isDown, player) ->
				{
					if (isDown)
						target.right.on_press();
					else
						target.right.on_release();
				},
				up: true
			},
			"up" => {
				action: (isDown, player) ->
				{
					if (isDown)
					{
						target.up.on_press();
					}
					else
					{
						target.up.on_release();
					}
				},
				up: true
			},
			"down" => {
				action: (isDown, player) ->
				{
					if (isDown)
						if (isDown)
							target.down.on_press();
						else
							target.down.on_release();
				},
				up: true
			},
			"b" => {
				action: (isDown, player) ->
				{
					if (isDown)
						target.b.on_press();
					else
						target.b.on_release();
				},
				up: true
			},
			"a" => {
				action: (isDown, player) ->
				{
					if (isDown)
						target.a.on_press();
					else
						target.a.on_release();
				},
				up: true
			},
			"select" => {
				action: (isDown, player) ->
				{
					if (isDown)
						target.select.on_press();
					else
						target.select.on_release();
				},
				up: true
			},
			"start" => {
				action: (isDown, player) ->
				{
					if (isDown)
						target.start.on_press();
					else
						target.start.on_release();
				},
				up: true
			}
		];

		var action_config = Controller.init_action_config();

		input2Action = new Input2Action();

		var keyboard_action = new KeyboardAction(action_config, action_map);

		input2Action.addKeyboard(keyboard_action);

		Gamepad.onConnect.add(gamepad -> {
			var gamepad_action = new GamepadAction(gamepad.id, action_config, action_map);
			input2Action.addGamepad(gamepad, gamepad_action);
			gamepad.onDisconnect.add(() -> input2Action.removeGamepad(gamepad));
		});

		input2Action.registerKeyboardEvents(window);
	}

	public function change_target(target: ControllerActions)
	{
		this.target = target;
	}
}
