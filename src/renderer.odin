package soko_knight

import rl "vendor:raylib"

draw_renderer :: proc(using r: ^rl.RenderTexture) {
	screen_width, screen_height := f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())

	scale := min(screen_width / f32(texture.width), screen_height / f32(texture.height))

	dest_width, dest_height := f32(texture.width) * scale, f32(texture.height) * scale

	offset_x, offset_y := (screen_width - dest_width) * 0.5, (screen_height - dest_height) * 0.5

	src_rec := rl.Rectangle{0, 0, f32(texture.width), -f32(texture.height)}
	dest_rec := rl.Rectangle{offset_x, offset_y, dest_width, dest_height}

	rl.DrawTexturePro(texture, src_rec, dest_rec, {0, 0}, 0, rl.WHITE)
}

screen_to_renderer :: proc(
	renderer: rl.RenderTexture,
	cam: rl.Camera2D,
	pos: rl.Vector2,
) -> rl.Vector2 {
	screen_width, screen_height := f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())
	scale := min(
		screen_width / f32(renderer.texture.width),
		screen_height / f32(renderer.texture.height),
	)

	new_width := f32(renderer.texture.width) * scale
	new_height := f32(renderer.texture.height) * scale

	offset_x := (screen_width - new_width) * 0.5
	offset_y := (screen_height - new_height) * 0.5

	virtual_x := (pos.x - offset_x) / scale
	virtual_y := (pos.y - offset_y) / scale
	virtual_pos := rl.Vector2{virtual_x, virtual_y}

	return rl.GetScreenToWorld2D(virtual_pos, cam)
}

renderer_to_screen :: proc(
	renderer: rl.RenderTexture,
	cam: rl.Camera2D,
	pos: rl.Vector2,
) -> rl.Vector2 {
	virtual_pos := rl.GetWorldToScreen2D(pos, cam)

	screen_width := f32(rl.GetScreenWidth())
	screen_height := f32(rl.GetScreenHeight())

	scale := min(
		screen_width / f32(renderer.texture.width),
		screen_height / f32(renderer.texture.height),
	)

	new_width := f32(renderer.texture.width) * scale
	new_height := f32(renderer.texture.height) * scale

	offset_x := (screen_width - new_width) * 0.5
	offset_y := (screen_height - new_height) * 0.5

	screen_x := (virtual_pos.x * scale) + offset_x
	screen_y := (virtual_pos.y * scale) + offset_y

	return {screen_x, screen_y}
}
