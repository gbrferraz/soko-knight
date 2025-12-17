package soko_knight

import "core:fmt"
import "core:mem"
import "core:os"

MAGIC_NUMBER :: 0x504B4F53
FILE_VERSION :: 1

Level :: struct {
	entities: [dynamic]Entity,
	tilemap:  Tilemap,
}

save_level :: proc(level: Level, path: string) {
	handle, err := os.open(path, os.O_WRONLY | os.O_CREATE | os.O_TRUNC, 0o644)
	if err != os.ERROR_NONE {
		fmt.printfln("Failed to open file for writing: %v", err)
		return
	}
	defer os.close(handle)

	magic := u32(MAGIC_NUMBER)
	version := u32(FILE_VERSION)
	os.write(handle, mem.ptr_to_bytes(&magic))
	os.write(handle, mem.ptr_to_bytes(&version))

	entity_count := i32(len(level.entities))
	os.write(handle, mem.ptr_to_bytes(&entity_count))

	if entity_count > 0 {
		raw_entities := mem.slice_to_bytes(level.entities[:])
		os.write(handle, raw_entities)
	}

	chunk_count := i32(len(level.tilemap.chunks))
	os.write(handle, mem.ptr_to_bytes(&chunk_count))

	for pos, chunk in level.tilemap.chunks {
		pos := pos
		os.write(handle, mem.ptr_to_bytes(&pos))

		chunk := chunk
		os.write(handle, mem.ptr_to_bytes(&chunk.tiles))
	}

	fmt.printfln("Level saved")
}

load_level :: proc(path: string) -> Level {
	level: Level
	level.tilemap.chunks = make(map[Vec2i]Chunk)

	// Read the whole file into memory first (simplest way)
	data, ok := os.read_entire_file(path)
	if !ok {
		fmt.printfln("Level file not found")
		return level
	}
	defer delete(data)

	// We will use an offset to track where we are reading in the byte array
	offset := 0

	// Helper to read a specific type T from the byte array
	read_type :: proc($T: typeid, data: []byte, offset: ^int) -> T {
		// Safety check (omitted for brevity, but you should check bounds!)
		size := size_of(T)
		val := (^T)(&data[offset^])^ // Cast raw bytes at offset to type T
		offset^ += size
		return val
	}

	// 1. Read & Verify Header
	magic := read_type(u32, data, &offset)
	if magic != MAGIC_NUMBER {
		fmt.printfln("Invalid file format!")
		return level
	}

	version := read_type(u32, data, &offset)
	if version != FILE_VERSION {
		fmt.printfln("Version mismatch! Expected %d, got %d", FILE_VERSION, version)
		// handle migration here if needed
	}

	// 2. Read Entities
	entity_count := read_type(i32, data, &offset)

	// Resize dynamic array to fit
	resize(&level.entities, int(entity_count))

	// Copy entity data in bulk
	if entity_count > 0 {
		size_bytes := int(entity_count) * size_of(Entity)
		mem.copy(&level.entities[0], &data[offset], size_bytes)
		offset += size_bytes
	}

	// 3. Read Chunks
	chunk_count := read_type(i32, data, &offset)

	for _ in 0 ..< chunk_count {
		// Read Position
		pos := read_type(Vec2i, data, &offset)

		// Read Chunk Data
		// We read the whole array of tiles at once
		tiles := read_type([CHUNK_W * CHUNK_H]TileType, data, &offset)

		// Insert into map
		new_chunk := Chunk {
			tiles = tiles,
		}
		level.tilemap.chunks[pos] = new_chunk
	}

	fmt.printfln("Level loaded")
	return level
}
