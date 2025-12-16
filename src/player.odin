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
		try_interact(entity, game)
		rl.PlaySound(game.step_sound)
	}
}

try_interact :: proc(entity: ^Entity, game: ^Game) {
	for interactable, i in game.level.entities {
		if entity.pos == interactable.pos {
			#partial switch interactable.type {
			case .Collectable:
				game.collected += 1
				unordered_remove(&game.level.entities, i)
			case .Key:
				unordered_remove(&game.level.entities, i)
			}
		}
	}
}
