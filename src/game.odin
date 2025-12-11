package soko_knight

import rl "vendor:raylib"

TILE_SIZE :: 10

Vec2i :: [2]int

Game :: struct {
	world_camera:  rl.Camera2D,
	screen_camera: rl.Camera2D,
	renderer:      rl.RenderTexture,
	state:         GameState,
	level:         Level,
	atlas:         rl.Texture2D,
}

GameState :: enum {
	Gameplay,
	Editor,
}

init_game :: proc() -> Game {
	game := Game {
		world_camera = {zoom = 1},
		screen_camera = {zoom = 1},
		renderer = rl.LoadRenderTexture(320, 180),
		atlas = rl.LoadTexture("res/ase/tileset.png"),
		level = load_level("levels/level.json"),
	}

	return game
}

update_game :: proc(using game: ^Game) {
	update_entities(game)
}

draw_game :: proc(using game: ^Game) {
	draw_tilemap(game)
	for entity in level.entities {
		draw_entity(entity, game)
	}
}

get_sprite_src_rect :: proc(coord: Vec2i) -> rl.Rectangle {
	return {f32(coord.x * TILE_SIZE), f32(coord.y * TILE_SIZE), f32(TILE_SIZE), f32(TILE_SIZE)}
}

unload_game :: proc(game: ^Game) {
	rl.UnloadRenderTexture(game.renderer)
}
