package soko_knight

import rl "vendor:raylib"

main :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	rl.InitWindow(1280, 720, "Sokoban Adventure")

	game := init_game()
	editor: Editor

	crt_shader := rl.LoadShader(nil, "src/shaders/crt.fs")
	loc_render_size := rl.GetShaderLocation(crt_shader, "renderSize")
	loc_time := rl.GetShaderLocation(crt_shader, "time")

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


		render_w := f32(game.renderer.texture.width)
		render_h := f32(game.renderer.texture.height)
		render_size := [2]f32{render_w, render_h}
		rl.SetShaderValue(crt_shader, loc_render_size, &render_size, .VEC2)

		time_seconds := f32(rl.GetTime())
		rl.SetShaderValue(crt_shader, loc_time, &time_seconds, .FLOAT)

		rl.BeginMode2D(game.screen_camera)

		rl.BeginShaderMode(crt_shader)
		draw_renderer(&game.renderer)
		rl.EndShaderMode()

		if game.state == .Editor {
			draw_screen_editor(&editor, &game)
		}

		rl.DrawFPS(10, 10)

		rl.EndMode2D()

		rl.EndDrawing()
	}

	rl.UnloadShader(crt_shader)
	unload_game(&game)
	rl.CloseWindow()
}
