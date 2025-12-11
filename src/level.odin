package soko_knight

import "core:encoding/json"
import "core:fmt"
import "core:os"

Level :: struct {
	entities: [dynamic]Entity,
	tilemap:  Tilemap,
}

save_level :: proc(level: Level, path: string) {
	if level_data, error := json.marshal(level); error == nil {
		os.write_entire_file(path, level_data)
		fmt.printfln("Level saved")
	}
}

@(require_results)
load_level :: proc(path: string) -> Level {
	level: Level

	level.tilemap.width = 32
	level.tilemap.height = 18

	level.tilemap.data = make([]TileType, level.tilemap.width * level.tilemap.height)

	if level_data, ok := os.read_entire_file(path); ok {
		defer delete(level_data)

		if json.unmarshal(level_data, &level) == nil {
			fmt.printfln("Level loaded")
			return level
		}
	}

	fmt.printfln("Level not loaded")
	return level
}
