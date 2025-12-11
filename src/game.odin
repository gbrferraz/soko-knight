package soko_knight

import rl "vendor:raylib"

Vec2i :: [2]int

TILE_SIZE :: 16

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

	game.level.tilemap.data = make(
		[]TileType,
		game.level.tilemap.width * game.level.tilemap.height,
	)

	box := Entity {
		type = .Box,
		pos  = {3, 3},
	}

	player := Entity {
		type = .Player,
		pos  = {5, 5},
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
	save_level(game.level, "levels/level.json")
	rl.UnloadRenderTexture(game.renderer)
}
