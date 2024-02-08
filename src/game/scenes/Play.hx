package game.scenes;

import game.Guard;
import game.HudMenu;
import game.LdtkData;
import game.LockedWall;
import game.Player;
import game.Scene;
import game.scenes.Title;
import game.Sounds;
import lib.ldtk.TileMapping;
import lib.peote.Camera;
import lib.peote.Elements;
import lib.peote.Glyph;
import lib.pure.Bresenham;
import lib.pure.Calculate;
import lib.pure.Rectangle;
import lime.utils.Assets;
import peote.view.Display;
import peote.view.utils.BlendFactor;
import peote.view.utils.BlendFunc;

using lib.peote.TextureTools;

class Play extends Scene
{
	var tile_size_px = 32;
	var sprite_size_px = 96;

	var fills: Fills;
	var locked_wall: LockedWall;
	var camera: Camera;
	var player: Player;
	var guards: Array<Guard>;
	var goals: Array<Goal>;
	var level: LdtkData_Level;

	var sprites_entities: Sprites;

	var tiles_level_behind: Tiles;
	var tiles_level_in_front: Tiles;
	var tiles_level_decor: Tiles;

	var restart_locations: Map<Int, Array<Int>>;
	var restart_gates: Array<Gate>;

	var is_checking_gates: Bool = false;

	var restart_key: Int;
	var glyphs_entity: Glyphs;
	var glyphs_front: Glyphs;
	var sacred_stone: Sprite;
	var is_goal_reached: Bool;
	var color_blocks: Fills;
	var steps_until_end: Int;

	public function new(core: GameCore)
	{
		var menu_config: MenuConfig = {
			introduction: [],
			items: [
				{
					label: "CONTINUE LEVEL",
					action: () ->
					{
						menu_close();
					},
				},
				{
					label: "RESTART LEVEL",
					action: () -> core.scene_reset(),
					// action: () -> core.scene_change(core -> new Play(core)),
				},
				{
					label: "EXIT TO TITLE",
					action: () -> change(core -> new Title(core)),
				},
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
			]
		}
		super(core, menu_config);
	}

	public function begin()
	{
		init_graphics();

		init_level();

		var column = restart_locations[restart_key][0];
		var row = restart_locations[restart_key][1];

		player = new Player(
			core.sound,
			glyphs_entity.make_line(0, 0, " ", 0x00000000), // icon
			glyphs_front.make_line(0, 0, " ", 0x00000000), // thoughts
			fills.make_aligned(column, row, tile_size_px, tile_size_px, tile_size_px, 0xe0e0e000),
			sprites_entities.make_aligned(column, row, tile_size_px, 10),
			column,
			row,
			tile_size_px,
			(column, row) -> map_collision_function(column, row, true)
		);

		guards = [
			for (guard in level.l_Entities.all_Guard)
				new Guard(
					core.sound,
					glyphs_entity.make_line(0, 0, " ", 0xffffff00), // icon
					glyphs_front.make_line(0, 0, " ", 0x00000000), // thought
					guard,
					fills.make_aligned(column, row, tile_size_px, tile_size_px, tile_size_px, 0xe0e0e000),
					sprites_entities.make_aligned(column, row, tile_size_px, 10),
					guard.cx,
					guard.cy,
					tile_size_px,
					(column, row) -> map_collision_function(column, row, true)
				)
		];

		controller.left.on_press = () ->
		{
			if (player.state.key == DEATH || player.state.key == HURT || player.state.key_next == HURT)
				return;

			player.is_movement_button_held = true;
			player.move_in_direction_x(-1);
		}

		controller.left.on_release = () ->
		{
			player.is_movement_button_held = false;
			player.stop_x();
		}

		controller.right.on_press = () ->
		{
			if (player.state.key == DEATH || player.state.key == HURT || player.state.key_next == HURT)
				return;
			player.is_movement_button_held = true;
			player.move_in_direction_x(1);
		}

		controller.right.on_release = () ->
		{
			player.is_movement_button_held = false;
			player.stop_x();
		}

		controller.a.on_press = () ->
		{
			if (player.state.key == DEATH || player.state.key == HURT || player.state.key_next == HURT)
				return;
			player.jump();
		}

		controller.a.on_release = () -> {
			// player.drop();
		}

		controller.b.on_press = () ->
		{
			if (player.state.key == DEATH || player.state.key == HURT || player.state.key_next == HURT)
				return;
			player.dash();
		}

		camera.center_on(player.movement.position.x, player.movement.position.y);
		camera.toggle_debug();

		core.input.change_target(controller);

		var total_tiles = 0;
		total_tiles += tiles_level_behind.total;
		total_tiles += tiles_level_decor.total;
		total_tiles += tiles_level_in_front.total;

		trace('begin play ${Date.now()} $total_tiles camera boundary is ${camera.scroll.boundary_floor}');
		core.sound.play_sound(BEGIN);
	}

	function map_collision_function(column: Int, row: Int, is_player: Bool)
	{
		// if platform is "locked"
		if (level.l_PlatformCollisions.hasValue(column, row, 4))
		{
			// this is a locked wall, it is a collision if the key is not held
			if (locked_wall.is_locked)
			{
				if (player.is_holding_key)
				{
					// if wall is visually locked but hey is held, hide the wall
					locked_wall.unlock();
					player.hide_icon();
				}
				else
				{
					if (is_player)
					{
						player.show_thought("IT IS LOCKED!");
					}
				}
			}
			return !player.is_holding_key;
		}

		// if roll is needed
		if (level.l_PlatformCollisions.hasValue(column, row, 5))
		{
			if (player.state.key == ROLL_GROUND || player.state_next == ROLL_GROUND)
			{
				// we rollin so don't collide
				return false;
			}

			if (is_player)
			{
				player.show_thought('I CAN ROLL UNDER?');
			}
			// collides
			return true;
		}

		// default platform collisions
		return level.l_PlatformCollisions.hasValue(column, row, 1) || level.l_PlatformCollisions.hasValue(column, row, 2);
	}

	function init_tiles(display: Display, name: String, asset_path: String, tile_size_px: Int): Tiles
	{
		var asset = Assets.getImage(asset_path);
		var texture = asset.tilesheet_from_image(tile_size_px, tile_size_px);

		return new Tiles(display, texture, name, tile_size_px);
	}

	function init_graphics()
	{
		color_blocks = new Fills(core.screen.display_level_behind);
		fills = new Fills(core.screen.display_level_in_front);

		// sprite sheet for level tiles
		tiles_level_behind = init_tiles(
			core.screen.display_level_behind,
			"level_behind",
			"assets/level-tiles.png",
			tile_size_px
		);

		// sprite sheet for decor
		tiles_level_decor = init_tiles(
			core.screen.display_level_behind,
			"level_decor",
			"assets/furniture.png",
			tile_size_px
		);

		@:privateAccess
		var program = tiles_level_decor.program;
		program.blendFunc = BlendFunc.ADD;
		program.blendSrc = BlendFactor.DST_COLOR;
		program.blendDst = BlendFactor.SRC_COLOR;

		@:privateAccess
		var program = tiles_level_behind.program;
		program.blendFunc = BlendFunc.ADD;
		program.blendSrc = BlendFactor.ZERO;
		program.blendDst = BlendFactor.SRC_COLOR;

		// sprite sheet for entities
		var template_asset = Assets.getImage("assets/sprites.png");
		var sprite_texture = template_asset.tilesheet_from_image(sprite_size_px, sprite_size_px);
		sprites_entities = new Sprites(
			core.screen.display_entities,
			sprite_texture,
			"samurai",
			sprite_size_px,
			sprite_size_px
		);

		tiles_level_in_front = new Tiles(
			core.screen.display_level_in_front,
			tiles_level_behind.texture,
			"level_in_front",
			tile_size_px,
		);

		// load level data
		glyphs_entity = new Glyphs(core.screen.display_icons, {
			tile_width: 16,
			tile_height: 16,
			tile_asset_path: "assets/font-shuriken-16x16.png",
			element_width: 16,
			element_height: 16,
			element_count: 128,
		});

		glyphs_front = new Glyphs(core.screen.display_level_in_front, {
			tile_width: 16,
			tile_height: 16,
			tile_asset_path: "assets/font-shuriken-16x16.png",
			element_width: 16,
			element_height: 16,
			element_count: 128,
		});
	}

	function init_level()
	{
		var is_level_visible = false;
		var is_level_visible = true;
		var zoom = 1;

		var level_index = 0; // test level
		var level_index = 1; // massive platformer

		restart_key = 3; // start of main building
		restart_key = 2; // tower
		restart_key = 0; // beginning (cellar)

		var levels = new LdtkData();
		level = levels.all_worlds.Default.levels[level_index];

		var make_rect: Entity_RestartGate -> Rectangle = gate -> {
			x: gate.cx,
			y: gate.cy,
			width: gate.width / tile_size_px,
			height: gate.height / tile_size_px
		}

		var make_gate: Entity_RestartGate -> Gate = gate ->
		{
			var g: Gate = {
				restart_key: gate.f_Index,
				rectangle: make_rect(gate)
			};
			// for debugging gates
			// fills.make_rectangle_element(
			// 	g.rectangle.x * tile_size_px,
			// 	g.rectangle.y * tile_size_px,
			// 	g.rectangle.width * tile_size_px,
			// 	g.rectangle.height * tile_size_px,
			// 	false,
			// 	0xea551ad0
			// );
			g;
		}

		// fills.update_all();

		restart_locations = [];
		for (location in level.l_Entities.all_RestartLocation)
		{
			restart_locations[location.f_Index] = [location.cx, location.cy];
		}
		restart_gates = level.l_Entities.all_RestartGate.map(gate -> make_gate(gate));

		var boundary_right = Std.int(level.l_Tiles_behind.cWid * tile_size_px);
		var boundary_floor = Std.int(level.l_Tiles_behind.cHei * tile_size_px);

		for (block in level.l_ColorBlocks.all_Block)
		{
			var tint = block.f_isUnderground ? 0x2b2821ff : 0xb1a58dff;

			color_blocks.make_aligned(block.cx, block.cy, tile_size_px, block.width, block.height, tint,);
		}
		color_blocks.update_all();

		if (is_level_visible)
		{
			// draw level tiles BEHIND
			iterate_layer(level.l_Tiles_behind, (tile_stack, column, row) ->
			{
				// get the top tile of the stack only
				var tile = tile_stack[tile_stack.length - 1];
				var is_flipped_x = tile.flipBits == 1;
				tiles_level_behind.make_aligned(column, row, tile_size_px, tile.tileId, is_flipped_x,);
			});

			tiles_level_behind.update_all();

			// draw tiles DECOR
			iterate_layer(level.l_Tiles_decor, (tile_stack, column, row) ->
			{
				// get the top tile of the stack only
				var tile = tile_stack[tile_stack.length - 1];
				var is_flipped_x = tile.flipBits == 1;
				tiles_level_decor.make_aligned(column, row, tile_size_px, tile.tileId, is_flipped_x,);
			});

			tiles_level_decor.update_all();

			// draw level tiles IN FRONT
			iterate_layer(level.l_Tiles_in_front, (tile_stack, column, row) ->
			{
				for (tile in tile_stack)
				{
					var is_flipped_x = tile.flipBits == 1;
					tiles_level_in_front.make_aligned(column, row, tile_size_px, tile.tileId, is_flipped_x,);
				}
			});

			tiles_level_in_front.update_all();
		}

		locked_wall = new LockedWall(fills);
		for (key in level.l_Entities.all_Key)
		{
			var glyph = glyphs_entity.make_line(
				Std.int((key.cx * tile_size_px) + tile_size_px / 2 - (glyphs_entity.font.tile_width / 2)),
				Std.int((key.cy * tile_size_px) + tile_size_px / 2 - (glyphs_entity.font.tile_width / 2)),
				"#",
				0xe8a40aff
			);
			locked_wall.add_key(glyph);
		}

		for (key in level.l_Entities.all_KeyHole)
		{
			var glyph = glyphs_front.make_line(
				Std.int((key.cx * tile_size_px) + tile_size_px / 2 - (glyphs_front.font.tile_width / 2)),
				Std.int((key.cy * tile_size_px) + tile_size_px / 2 - (glyphs_front.font.tile_width / 2)),
				"$",
				0x0a0a0aff
			);
			locked_wall.add_key_hole(glyph);
		}

		// draw some fills where the collision tiles are
		iterate_grid(level.l_PlatformCollisions, (value, column, row) ->
		{
			var is_underground = row >= 50;
			var is_locked = value == 4;
			if (is_locked)
			{
				locked_wall.add_block(fills.make_aligned(
					column,
					row,
					tile_size_px,
					tile_size_px,
					tile_size_px,
					value = is_underground ? 0x624c3cff : 0xb03a48ff
				));
			}
			else
			{
				var is_platform = value == 1 || value == 2;
				fills.make_aligned(
					column,
					row,
					tile_size_px,
					tile_size_px,
					tile_size_px,
					value = is_platform ? (is_underground ? 0x624c3cff : 0xb03a48ff) : 0xb1a58d00
				);
			}
		});

		fills.update_all();

		goals = [
			for (goal in level.l_Entities.all_Goal)
				{
					column: goal.cx,
					row: goal.cy,
					graphic: color_blocks.make_aligned(goal.cx, goal.cy, tile_size_px, goal.width, goal.height, 0xffffff2a,),
					completed_tint: 0x3e695800
				}
		];

		if (level.l_Entities.all_Flower.length > 0)
		{
			var sacred_stone = level.l_Entities.all_Flower[0];
			this.sacred_stone = sprites_entities.make_aligned(
				sacred_stone.cx,
				sacred_stone.cy,
				tile_size_px,
				(Samurai.animation_sheet_columns * Samurai.animation_sheet_rows) + Samurai.animation_sheet_columns - 1
			);
		}

		var scrollable_displays: Array<Display> = [
			core.screen.display_bg,
			core.screen.display_level_behind,
			core.screen.display_entities,
			core.screen.display_icons,
			core.screen.display_level_in_front,
		];

		camera = new Camera(scrollable_displays, {
			view_width: core.screen.display_width,
			view_height: core.screen.display_height,
			boundary_left: 0,
			boundary_right: boundary_right,
			boundary_ceiling: 0,
			boundary_floor: boundary_floor,
			zone_center_x: 0,
			zone_center_y: 0,
			zone_width: 128,
			zone_height: 96
		});
	}

	/**
		#2b2821
		#624c3c
		#d9ac8b
		#e3cfb4
		#243d5c
		#5d7275
		#5c8b93
		#b1a58d
		#b03a48
		#d4804d
		#e0c872
		#3e6958

	**/
	function update_guard(samurai: Guard)
	{
		if (player.can_be_killed())
		{
			var x_delta = player.movement.position.grid_x - samurai.movement.position.grid_x;
			var x_grid_distance = Math.abs(x_delta);
			var y_delta = player.movement.position.grid_y - samurai.movement.position.grid_y;
			var y_grid_distance = Math.abs(y_delta);
			// fast distance check - is distance close enough to be seen?
			final sight_grid_limit = samurai.ldtk_entity.f_wakeDistance;
			final sight_grid_minimum = 1;

			var x_pixel_distance = player.movement.position.x - samurai.movement.position.x;
			var direction_of_player = x_pixel_distance > 1 ? 1 : -1;
			var samurai_is_facing_player = samurai.facing == direction_of_player;

			if (samurai.is_moving_x && !samurai_is_facing_player)
			{
				samurai.stop_x();
				return;
			}

			if (samurai.ldtk_entity.f_wakeOn == Enum_WakeOn.Flower && !player.is_holding_sacred_stone)
			{
				return;
			}

			var samurai_can_attack = (player.state.key != HURT && player.state.key != DEATH && player.state.key != ROLL_GROUND)
				&& player.movement.is_on_ground
				&& samurai_is_facing_player
				&& (player.is_in_cell(samurai.movement.position.grid_x + direction_of_player, samurai.movement.position.grid_y)
					|| player.is_in_cell(samurai.movement.position.grid_x, samurai.movement.position.grid_y));

			if (samurai_can_attack)
			{
				trace('samurai attack');
				if (samurai.is_moving_x)
				{
					samurai.stop_x();
				}
				samurai.state.key_next = SWORD;
				core.sound.play_sound(SoundKey.SWIPE);

				player.stop_x();
				player.state.key_next = HURT;
				return;
			}

			var do_line_of_sight_check = samurai_is_facing_player
				&& (x_grid_distance <= sight_grid_limit && y_grid_distance <= sight_grid_limit && x_grid_distance > sight_grid_minimum);

			if (do_line_of_sight_check)
			{
				var is_actor_in_sight = !is_line_blocked(
					player.movement.position.grid_x,
					player.movement.position.grid_y,
					samurai.movement.position.grid_x,
					samurai.movement.position.grid_y,
					(grid_x, grid_y) -> level.l_PlatformCollisions.hasValue(grid_x, grid_y)
				);

				if (is_actor_in_sight)
				{
					samurai.move_in_direction_x(direction_of_player);
					samurai.set_alertness(true);
				}
			}
		}

		samurai.update();
	}

	function reset_to_checkpoint()
	{
		for (guard in guards)
		{
			guard.reset();
		}
		var restart_coord = restart_locations[restart_key];
		player.movement.teleport_to_grid(restart_coord[0], restart_coord[1]);
		player.change_state(IDLE);
		locked_wall.reset();
		player.reset();
	}

	override function update()
	{
		super.update();
		if (player.state.key == DEATH)
		{
			if (player.animation_frame >= player.animation.frame_count - 1)
			{
				if (!core.scene.shutter.is_closing)
				{
					core.scene.shutter.close_shutter(10);
				}
				if (core.scene.shutter.is_closed && !core.scene.shutter.is_opening)
				{
					reset_to_checkpoint();
					core.scene.shutter.open_shutter(10);
				}
			}
		}
		else
		{
			is_checking_gates = true;
			for (gate in restart_gates)
			{
				if (is_checking_gates)
				{
					if (gate.rectangle.is_inside(player.movement.position.grid_x, player.movement.position.grid_y))
					{
						restart_key = gate.restart_key;
						is_checking_gates = false;
						trace('\n~~~ RESTART gate is now $restart_key \n');
					}
				}
			}

			if (!player.is_holding_key && locked_wall.is_overlapping_key(player.movement.position.x, player.movement.position.y))
			{
				locked_wall.hide_key();
				player.collect_key();
			}

			if (!player.is_holding_sacred_stone && sacred_stone.tint.a != 0x00)
			{
				if (distance_to_point(
					player.movement.position.x,
					player.movement.position.y,
					sacred_stone.x,
					sacred_stone.y
				) <= 20)
				{
					sacred_stone.tint.a = 0x00;
					player.collect_sacred_stone();
				}
			}

			for (samurai in guards)
			{
				update_guard(samurai);
			}

			if (player.state.key == DEATH || player.state.key == HURT || player.state.key_next == HURT)
			{
				player.stop_x();
				player.state.key_next = HURT;
			}

			for (goal in goals)
			{
				if (player.is_in_rectangle(
					goal.graphic.x,
					goal.graphic.y,
					goal.graphic.width,
					goal.graphic.height
				))
				{
					if (!is_goal_reached)
					{
						if (player.is_holding_sacred_stone)
						{
							sacred_stone.x = goal.graphic.x + (goal.graphic.width / 2);
							sacred_stone.y = goal.graphic.y + (goal.graphic.height / 2);
							sacred_stone.tint.a = 0xff;
							is_goal_reached = true;
							core.sound.play_sound(SoundKey.WIN);
							player.hide_icon();
						}
						else
						{
							player.show_thought("I NEED THE STONE");
						}
						steps_until_end = 240;
					}
				}
			}
		}

		if (is_goal_reached)
		{
			steps_until_end--;
			if (steps_until_end <= 0)
			{
				core.scene_change(core -> new End(core));
			}
		}
		else
		{
			player.update();

			var target_width_offset = (8 / 2);
			var target_height_offset = (8 / 2);
			var target_left = player.movement.position.x - target_width_offset;
			var target_right = player.movement.position.x + target_width_offset;
			var target_ceiling = player.movement.position.y - target_height_offset;
			var target_floor = player.movement.position.y + target_height_offset;

			camera.follow_target(target_left, target_right, target_ceiling, target_floor);
		}
	}

	public function draw(step_ratio: Float)
	{
		if (!is_goal_reached)
		{
			player.draw(step_ratio);

			for (samurai in guards)
			{
				samurai.draw(step_ratio);
			}

			camera.draw(step_ratio);
			glyphs_entity.update();
		}
		sprites_entities.update_all();
	}

	public function end()
	{
		fills.clear();
		tiles_level_behind.clear();
		sprites_entities.clear();
		tiles_level_in_front.clear();
		camera.clear();
	}
}

@:structInit
@:publicFields
class Goal
{
	var column: Int;
	var row: Int;
	var graphic: Fill;
	var completed_tint: Int;
}

@:structInit
@:publicFields
class Gate
{
	var restart_key: Int;
	var rectangle: Rectangle;
}
