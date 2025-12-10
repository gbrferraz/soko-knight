package soko_knight

import rl "vendor:raylib"

Vec2i :: [2]int

TILE_SIZE :: 16

Game :: struct {
	world_camera:  rl.Camera2D,
	screen_camera: rl.Camera2D,
	canvas:        Canvas,
	entities:      [dynamic]Entity,
	state:         GameState,
	atlas:         rl.Texture2D,
	tilemap:       Tilemap,
}

GameState :: enum {
	Gameplay,
	Editor,
}

init_game :: proc() -> Game {
	game := Game {
		world_camera = {zoom = 1},
		screen_camera = {zoom = 1},
		canvas = init_canvas(320, 180),
		atlas = rl.LoadTexture("res/ase/tileset.png"),
		tilemap = {width = 10, height = 10},
	}

	game.tilemap.data = make([]TileType, game.tilemap.width * game.tilemap.height)
	game.tilemap.data[2] = .Wall
	game.tilemap.data[44] = .Wall

	box := Entity {
		type = .Box,
		pos  = {3, 3},
	}

	player := Entity {
		type = .Player,
		pos  = {5, 5},
	}

	append(&game.entities, box)
	append(&game.entities, player)

	return game
}

update_game :: proc(using game: ^Game) {
	update_entities(game)
}

draw_game :: proc(using game: ^Game) {
	draw_tilemap(game)
	for entity in entities {
		draw_entity(entity, game)
	}
}

get_sprite_src_rect :: proc(coord: Vec2i) -> rl.Rectangle {
	return {f32(coord.x * TILE_SIZE), f32(coord.y * TILE_SIZE), f32(TILE_SIZE), f32(TILE_SIZE)}
}

unload_game :: proc(game: ^Game) {
	unload_virtual_screen(game.canvas)
}
