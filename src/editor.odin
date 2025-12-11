package soko_knight

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

Editor :: struct {
	mode:      EditorMode,
	selection: EditorSelection,
}

EditorMode :: enum {
	Entity,
	Tilemap,
}

EditorSelection :: union {
	EntityType,
	TileType,
}

drag_camera :: proc(camera: ^rl.Camera2D) {
	delta := rl.GetMouseDelta()
	delta = delta * (-1 / camera.zoom)
	camera.target += delta
}

place_selection :: proc(selection: EditorSelection, game: ^Game) {
	virtual_mouse := screen_to_renderer(game.renderer, game.world_camera, rl.GetMousePosition())

	grid_coord := Vec2i {
		int(math.floor(virtual_mouse.x / TILE_SIZE)),
		int(math.floor(virtual_mouse.y / TILE_SIZE)),
	}

	switch type in selection {
	case EntityType:
		entity_type := selection.(EntityType)
		new_entity := Entity {
			type = entity_type,
			pos  = grid_coord,
		}
		if _, ok := get_entity_at_pos(grid_coord, game.level.entities); !ok {
			append(&game.level.entities, new_entity)
		}
	case TileType:
	}
}

remove_selection :: proc(game: ^Game) {
	virtual_mouse := screen_to_renderer(game.renderer, game.world_camera, rl.GetMousePosition())

	grid_coord := Vec2i {
		int(math.floor(virtual_mouse.x / TILE_SIZE)),
		int(math.floor(virtual_mouse.y / TILE_SIZE)),
	}

	if entity_index, ok := get_entity_index_at_pos(grid_coord, game.level.entities); ok {
		unordered_remove(&game.level.entities, entity_index)
	}
}

update_editor :: proc(game: ^Game, editor: ^Editor) {
	if rl.IsMouseButtonDown(.MIDDLE) {
		drag_camera(&game.world_camera)
	}

	if rl.IsMouseButtonDown(.LEFT) {
		place_selection(editor.selection, game)
	}

	if rl.IsMouseButtonDown(.RIGHT) {
		remove_selection(game)
	}

	if rl.IsKeyPressed(.ONE) {editor.selection = .Box}
	if rl.IsKeyPressed(.TWO) {editor.selection = .Player}
	if rl.IsKeyPressed(.THREE) {editor.selection = .Ground}
	if rl.IsKeyPressed(.FOUR) {editor.selection = .Wall}
}

draw_screen_editor :: proc(editor: ^Editor, game: ^Game) {
	draw_mode_buttons()

	virtual_mouse := screen_to_renderer(game.renderer, game.world_camera, rl.GetMousePosition())

	tile_x := i32(math.floor(virtual_mouse.x / TILE_SIZE))
	tile_y := i32(math.floor(virtual_mouse.y / TILE_SIZE))

	coords := fmt.ctprintf("Grid: %d, %d", tile_x, tile_y)
	rl.DrawText(coords, 10, rl.GetScreenHeight() - 40, 30, rl.GREEN)

	selection_type := fmt.ctprintf("%v", editor.selection)
	rl.DrawText(selection_type, 10, 10, 30, rl.GREEN)
}

draw_canvas_editor :: proc(editor: ^Editor, game: ^Game) {
	virtual_mouse := screen_to_renderer(game.renderer, game.world_camera, rl.GetMousePosition())

	tile_x := i32(math.floor(virtual_mouse.x / TILE_SIZE)) * TILE_SIZE
	tile_y := i32(math.floor(virtual_mouse.y / TILE_SIZE)) * TILE_SIZE

	src: rl.Rectangle

	switch selection in editor.selection {
	case EntityType:
		entity_type := editor.selection.(EntityType)
		sprite_coord := ENTITY_SPRITES[entity_type]
		src = get_sprite_src_rect(sprite_coord)
	case TileType:
		tile_type := editor.selection.(TileType)
		sprite_coord := TILE_PROPERTIES[tile_type].sprite_coord
		src = get_sprite_src_rect(sprite_coord)
	}

	color := rl.Color{255, 255, 255, 100}
	rl.DrawTextureRec(game.atlas, src, {f32(tile_x), f32(tile_y)}, color)
}

draw_mode_buttons :: proc() {
	button_rec := rl.Rectangle{10, 10, 100, 100}
	rl.GuiButton(button_rec, "Dude")
}
