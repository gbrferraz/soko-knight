package soko_knight

import rl "vendor:raylib"

move_player :: proc(entity: ^Entity, game: ^Game) {
	dir: Vec2i
	if rl.IsKeyPressed(.W) || rl.IsKeyPressed(.UP) {
		dir = {0, -1}
	}
	if rl.IsKeyPressed(.S) || rl.IsKeyPressed(.DOWN) {
		dir = {0, 1}
	}
	if rl.IsKeyPressed(.A) || rl.IsKeyPressed(.LEFT) {
		dir = {-1, 0}
	}
	if rl.IsKeyPressed(.D) || rl.IsKeyPressed(.RIGHT) {
		dir = {1, 0}
	}

	if dir != {0, 0} {
		try_move(entity, dir, game)
	}
}
