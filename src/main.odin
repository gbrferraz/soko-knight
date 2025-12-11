package soko_knight

import rl "vendor:raylib"

main :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	rl.InitWindow(1280, 720, "Sokoban Adventure")
	rl.SetTargetFPS(60)

	game := init_game()
	editor: Editor

	for !rl.WindowShouldClose() {
		// UPDATE
		switch game.state {
		case .Gameplay:
			if rl.IsKeyPressed(.F1) {
				game.state = .Editor
			}
			update_game(&game)
		case .Editor:
			if rl.IsKeyPressed(.F1) {
				game.state = .Gameplay
			}
			update_editor(&game, &editor)
		}

		// DRAW //
		rl.BeginTextureMode(game.renderer)
		rl.BeginMode2D(game.world_camera)

		// GAME //
		rl.ClearBackground(rl.RAYWHITE)
		draw_game(&game)
		if game.state == .Editor {
			draw_canvas_editor(&editor, &game)
		}

		rl.EndMode2D()
		rl.EndTextureMode()

		// UI //
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		rl.BeginMode2D(game.screen_camera)

		draw_renderer(&game.renderer)

		if game.state == .Editor {
			draw_screen_editor(&editor, &game)
		}

		rl.EndMode2D()

		rl.EndDrawing()
	}

	unload_game(&game)
	rl.CloseWindow()
}
