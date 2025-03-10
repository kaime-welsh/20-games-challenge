package main

import rl "vendor:raylib"

GAME_TITLE :: "Jetpack"
GAME_WIDTH :: 640
GAME_HEIGHT :: 480

// This technically works, but I would like a better understanding of
// handles, what they are, and how to construct them?
last_entity_id: int = 0
EntityFlags :: enum {
	alive,
	dead,
	player,
}
Entity :: struct {
	id:    int,
	pos:   [2]f32,
	vel:   [2]f32,
	flags: bit_set[EntityFlags],
}
Entities: [1000]Entity

make_entity :: proc() -> int {
	for &entity in Entities {
		if !(.alive in entity.flags) { 	// found unused entity
			last_entity_id += 1 // increment id
			entity = Entity{} // clear entity data
			entity.flags += {.alive} // set entity as active
			entity.id = last_entity_id // assign new id to entity
			return entity.id
		}
	}

	rl.TraceLog(.ERROR, "Failed to allocate new entity! Increase entity limit!")
	return 0
}

get_entity :: proc(eid: int) -> ^Entity {
	if eid <= 0 || eid > last_entity_id {return nil} 	// bounds checking
	for &entity in Entities {
		if entity.id == eid && .alive in entity.flags {
			return &entity
		}
	}
	return nil
}

clean_entities :: proc() {
	for &entity in Entities {
		if .dead in entity.flags {
			entity = Entity{}
		}
	}
}

LOAD :: proc() {
}

UPDATE :: proc(dt: f32) {
	clean_entities()
}

DRAW :: proc() {
	rl.ClearBackground(rl.DARKGRAY)
}

UNLOAD :: proc() {}
