package soko_knight

import rl "vendor:raylib"

CHUNK_W :: 32
CHUNK_H :: 18

Tilemap :: struct {
	chunks: map[Vec2i]Chunk,
}

Chunk :: struct {
	tiles: [CHUNK_W * CHUNK_H]TileType,
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

get_chunk_and_index :: proc(pos: Vec2i) -> (Vec2i, int, bool) {
	if pos.x < 0 || pos.y < 0 {
		return {}, 0, false
	}

	chunk_x := pos.x / CHUNK_W
	chunk_y := pos.y / CHUNK_H

	local_x := pos.x % CHUNK_W
	local_y := pos.y % CHUNK_H

	local_index := local_y * CHUNK_W + local_x

	return {chunk_x, chunk_y}, local_index, true
}

draw_tilemap :: proc(using game: ^Game) {
	for chunk_coord, chunk in level.tilemap.chunks {
		start_x := f32(chunk_coord.x * CHUNK_W * TILE_SIZE)
		start_y := f32(chunk_coord.y * CHUNK_H * TILE_SIZE)

		for y in 0 ..< CHUNK_H {
			for x in 0 ..< CHUNK_W {
				tile := chunk.tiles[y * CHUNK_W + x]

				if tile == .Ground do continue

				sprite_coord := TILE_PROPERTIES[tile].sprite_coord

				src := get_sprite_src_rect(sprite_coord)
				dest := rl.Vector2{start_x + f32(x * TILE_SIZE), start_y + f32(y * TILE_SIZE)}

				rl.DrawTextureRec(atlas, src, dest, rl.WHITE)
			}
		}
	}
}

get_tile_at_pos :: proc(pos: Vec2i, tilemap: Tilemap) -> (TileType, bool) {
	chunk_pos, local_index, valid := get_chunk_and_index(pos)

	if chunk, ok := tilemap.chunks[chunk_pos]; ok {
		return chunk.tiles[local_index], true
	}

	return .Ground, false
}

set_tile_at_pos :: proc(tilemap: ^Tilemap, pos: Vec2i, type: TileType) {
	chunk_pos, local_index, valid := get_chunk_and_index(pos)
	if !valid {return}

	if chunk, ok := &tilemap.chunks[chunk_pos]; ok {
		chunk.tiles[local_index] = type
	} else {
		new_chunk := Chunk{}
		new_chunk.tiles[local_index] = type
		tilemap.chunks[chunk_pos] = new_chunk
	}
}
