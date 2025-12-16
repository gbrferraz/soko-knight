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
		if !try_move(entity, dir, game) {
			try_interact(entity, dir, game)
		}

		try_collect(entity, game)

		rl.PlaySound(game.step_sound)
	}
}

try_interact :: proc(entity: ^Entity, dir: Vec2i, game: ^Game) {
	for interactable, i in game.level.entities {
		if entity.pos + dir == interactable.pos {
			#partial switch interactable.type {
			case .Door:
				if game.keys > 0 {
					unordered_remove(&game.level.entities, i)
					game.keys -= 1
				}
			}
		}
	}
}

try_collect :: proc(entity: ^Entity, game: ^Game) {
	for collectable, i in game.level.entities {
		if entity.pos == collectable.pos {
			#partial switch collectable.type {
			case .Collectable:
				game.collected += 1
				unordered_remove(&game.level.entities, i)
			case .Key:
				game.keys += 1
				unordered_remove(&game.level.entities, i)
			}
		}
	}
}
