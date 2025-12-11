package soko_knight

import rl "vendor:raylib"

Tilemap :: struct {
	width:  int,
	height: int,
	data:   []TileType,
}

TileType :: enum {
	Ground,
	Wall,
}

TileProperty :: struct {
	sprite_coord: Vec2i,
	solid:        bool,
}

TILE_PROPERTIES := [TileType]TileProperty {
	.Ground = {sprite_coord = {0, 0}, solid = false},
	.Wall = {sprite_coord = {0, 1}, solid = true},
}

draw_tilemap :: proc(using game: ^Game) {
	for y in 0 ..< level.tilemap.height {
		for x in 0 ..< level.tilemap.width {
			index := y * level.tilemap.width + x
			tile_type := level.tilemap.data[index]
			sprite_coord := TILE_PROPERTIES[tile_type].sprite_coord
			src := get_sprite_src_rect(sprite_coord)
			dest := rl.Vector2{f32(x * TILE_SIZE), f32(y * TILE_SIZE)}

			rl.DrawTextureRec(atlas, src, dest, rl.WHITE)
		}
	}
}

get_tile_at_pos :: proc(using tilemap: Tilemap, pos: Vec2i) -> (TileType, bool) {
	if pos.y < 0 || pos.y >= height || pos.x < 0 || pos.x >= width {
		return nil, false
	}

	index := pos.y * width + pos.x
	tile_id := data[index]
	return tile_id, true
}

set_tile_at_pos :: proc(using tilemap: ^Tilemap, pos: Vec2i, type: TileType) {
	if pos.y < 0 || pos.y >= height || pos.x < 0 || pos.x >= width {
		return
	}

	index := pos.y * width + pos.x
	data[index] = type
}
