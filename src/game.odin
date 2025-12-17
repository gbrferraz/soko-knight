package soko_knight

import "core:fmt"
import rl "vendor:raylib"

TILE_SIZE :: 10
BG_COLOR :: rl.Color{36, 22, 39, 255}

Vec2i :: [2]int

Game :: struct {
	world_camera:  rl.Camera2D,
	screen_camera: rl.Camera2D,
	step_sound:    rl.Sound,
	renderer:      rl.RenderTexture,
	collected:     int,
	keys:          int,
	state:         GameState,
	level:         Level,
	atlas:         rl.Texture2D,
}

GameState :: enum {
	Intro,
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
		step_sound = rl.LoadSound("res/sound/step.wav"),
	}

	return game
}

update_game :: proc(using game: ^Game) {
	update_entities(game)
}

draw_game :: proc(using game: ^Game) {
	rl.ClearBackground(BG_COLOR)
	draw_tilemap(game)
	for entity in level.entities {
		draw_entity(entity, game)
	}
}

draw_game_ui :: proc(using game: ^Game) {
	collected_count := fmt.ctprintfln("x: %i", game.collected)
	rl.DrawText(collected_count, 10, 10, 0, {255, 191, 0, 255})

	key_count := fmt.ctprintfln("x: %i", game.keys)
	rl.DrawText(key_count, 10, 22, 0, {255, 191, 0, 255})
}

get_sprite_src_rect :: proc(coord: Vec2i) -> rl.Rectangle {
	return {f32(coord.x * TILE_SIZE), f32(coord.y * TILE_SIZE), f32(TILE_SIZE), f32(TILE_SIZE)}
}

unload_game :: proc(game: ^Game) {
	rl.UnloadRenderTexture(game.renderer)
}
