package soko_knight

import rl "vendor:raylib"

TileType :: enum int {
	Ground,
	Wall,
}

TileProperty :: struct {
	solid: bool,
}

TILE_SPRITES := [TileType]Vec2i {
	.Ground = {0, 0},
	.Wall   = {0, 1},
}

TILE_PROPERTIES := [TileType]TileProperty {
	.Ground = {false},
	.Wall   = {true},
}

Tilemap :: struct {
	width:  int,
	height: int,
	data:   []TileType,
}

draw_tilemap :: proc(using game: ^Game) {
	for y in 0 ..< tilemap.height {
		for x in 0 ..< tilemap.width {
			index := y * tilemap.width + x
			tile_type := tilemap.data[index]
			sprite_coord := TILE_SPRITES[tile_type]
			src := get_sprite_src_rect(sprite_coord)
			dest := rl.Vector2{f32(x * TILE_SIZE), f32(y * TILE_SIZE)}

			rl.DrawTextureRec(atlas, src, dest, rl.WHITE)
		}
	}
}

get_tile_at_pos :: proc(pos: Vec2i, using tilemap: Tilemap) -> (TileType, bool) {
	if pos.y < 0 || pos.y >= height || pos.x < 0 || pos.x >= width {
		return nil, false
	}

	index := pos.y * width + pos.x
	tile_id := data[index]
	return tile_id, true
}
