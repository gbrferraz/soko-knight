package soko_knight

import rl "vendor:raylib"

Entity :: struct {
	type: EntityType,
	pos:  Vec2i,
}

EntityType :: enum {
	Box,
	Player,
}

EntityProperties :: struct {
	solid:    bool,
	pushable: bool,
}

ENTITY_SPRITES := [EntityType]Vec2i {
	.Player = {1, 0},
	.Box    = {0, 2},
}

ENTITY_DEFINITIONS := [EntityType]EntityProperties {
	.Player = {solid = false, pushable = true},
	.Box = {solid = true, pushable = true},
}

draw_entity :: proc(using entity: Entity, game: ^Game) {
	sprite_coord := ENTITY_SPRITES[type]
	src := get_sprite_src_rect(sprite_coord)
	dest := rl.Vector2{f32(pos.x * TILE_SIZE), f32(pos.y * TILE_SIZE)}

	rl.DrawTextureRec(game.atlas, src, dest, rl.WHITE)
}

update_entities :: proc(using game: ^Game) {
	for &entity in level.entities {
		switch entity.type {
		case .Player:
			move_player(&entity, game)
		case .Box:

		}
	}
}

get_entity_at_pos :: proc(pos: Vec2i, entities: [dynamic]Entity) -> (^Entity, bool) {
	for &entity in entities {
		if entity.pos == pos {
			return &entity, true
		}
	}

	return nil, false
}

get_entity_index_at_pos :: proc(pos: Vec2i, entities: [dynamic]Entity) -> (int, bool) {
	for entity, index in entities {
		if entity.pos == pos {
			return index, true
		}
	}

	return -1, false
}

try_move :: proc(entity: ^Entity, dir: Vec2i, game: ^Game) -> bool {
	dest_pos := entity.pos + dir

	if obstacle, ok := get_entity_at_pos(dest_pos, game.level.entities); ok {
		if ENTITY_DEFINITIONS[obstacle.type].solid {
			can_push := false
			if ENTITY_DEFINITIONS[obstacle.type].pushable {
				if try_move(obstacle, dir, game) {
					can_push = true
				}

				if !can_push {
					return false
				}
			}
		}
	}

	if tile, ok := get_tile_at_pos(game.level.tilemap, dest_pos); ok {
		if TILE_PROPERTIES[tile].solid {
			return false
		}
	}

	entity.pos = dest_pos
	return true
}
