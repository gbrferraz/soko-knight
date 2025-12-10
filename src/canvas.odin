package soko_knight

import rl "vendor:raylib"

Canvas :: struct {
	render_texture: rl.RenderTexture,
	width, height:  i32,
}

init_canvas :: proc(width, height: i32) -> Canvas {
	virtual_screen := Canvas {
		width          = width,
		height         = height,
		render_texture = rl.LoadRenderTexture(width, height),
	}

	return virtual_screen
}

draw_canvas :: proc(canvas: ^Canvas) {
	screen_width, screen_height := f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())

	scale := min(screen_width / f32(canvas.width), screen_height / f32(canvas.height))
	dest_width, dest_height := f32(canvas.width) * scale, f32(canvas.height) * scale
	offset_x, offset_y := (screen_width - dest_width) * 0.5, (screen_height - dest_height) * 0.5

	src_rec := rl.Rectangle{0, 0, f32(canvas.width), -f32(canvas.height)}
	dest_rec := rl.Rectangle{offset_x, offset_y, dest_width, dest_height}

	rl.DrawTexturePro(canvas.render_texture.texture, src_rec, dest_rec, {0, 0}, 0, rl.WHITE)
}

unload_virtual_screen :: proc(vs: Canvas) {
	rl.UnloadRenderTexture(vs.render_texture)
}

screen_to_canvas :: proc(vs: Canvas, cam: rl.Camera2D, pos: rl.Vector2) -> rl.Vector2 {
	screen_width, screen_height := f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())
	scale := min(screen_width / f32(vs.width), screen_height / f32(vs.height))

	new_width := f32(vs.width) * scale
	new_height := f32(vs.height) * scale

	offset_x := (screen_width - new_width) * 0.5
	offset_y := (screen_height - new_height) * 0.5

	virtual_x := (pos.x - offset_x) / scale
	virtual_y := (pos.y - offset_y) / scale
	virtual_pos := rl.Vector2{virtual_x, virtual_y}

	return rl.GetScreenToWorld2D(virtual_pos, cam)
}

canvas_to_screen :: proc(canvas: Canvas, cam: rl.Camera2D, pos: rl.Vector2) -> rl.Vector2 {
	virtual_pos := rl.GetWorldToScreen2D(pos, cam)

	screen_width := f32(rl.GetScreenWidth())
	screen_height := f32(rl.GetScreenHeight())

	scale := min(screen_width / f32(canvas.width), screen_height / f32(canvas.height))

	new_width := f32(canvas.width) * scale
	new_height := f32(canvas.height) * scale

	offset_x := (screen_width - new_width) * 0.5
	offset_y := (screen_height - new_height) * 0.5

	screen_x := (virtual_pos.x * scale) + offset_x
	screen_y := (virtual_pos.y * scale) + offset_y

	return {screen_x, screen_y}
}
