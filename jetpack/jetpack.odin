package main

import "core:math/linalg"
import rl "vendor:raylib"

GAME_TITLE :: "Jetpack"
GAME_WIDTH :: 640
GAME_HEIGHT :: 480

// This technically works, but I would like a better understanding of
// handles, what they are, and how to construct them?
EntityHandle :: int
last_entity_id: int = 0
living_entities: int = 0
EntityFlags :: enum {
	alive,
	dead,
	player,
}
Entity :: struct {
	id:    EntityHandle,
	flags: bit_set[EntityFlags],
	type:  EntityType,
}
Entities: [1000]Entity

Player :: struct {
	pos:       [2]f32,
	vel:       [2]f32,
	thrust:    f32,
	radius:    f32,
	gravity:   f32,
	max_speed: f32,
}

Coin :: struct {
	pos:               [2]f32,
	radius:            f32,
	value:             int,
	collection_radius: f32,
}
EntityType :: union {
	Player,
	Coin,
}

make_entity :: proc(type: EntityType) -> EntityHandle {
	for &entity in Entities {
		if !(.alive in entity.flags) { 	// found unused entity
			last_entity_id += 1 // increment id
			living_entities += 1 // increment living entities count
			entity = Entity{} // clear entity data
			entity.flags += {.alive} // set entity as active
			entity.id = last_entity_id // assign new id to entity
			entity.type = type
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
			living_entities -= 1
		}
	}
}

GameState :: struct {
	game_speed:    f32,
	player_handle: EntityHandle,
	coin_timer:    f32,
	coin_time:     f32,
}
gs: GameState

LOAD :: proc() {
	gs = GameState{}
	gs.game_speed = 1.0
	gs.coin_time = 1.25
	gs.player_handle = make_entity(
		Player{pos = {128, 240}, thrust = 40, gravity = 15, radius = 16, max_speed = 400},
	)

}

UPDATE :: proc(dt: f32) {
	clean_entities()

	{ 	// Update coins
		gs.coin_timer -= dt
		if gs.coin_timer <= 0 {
			// TODO: I would like to make a system that create coins in patterns.
			// Could possibly just generate a random number of coins to spawn, then pick a height
			// for them to spawn at, and maybe just spawn from a slice or something?
			// idk i'll figure somethign out later

			make_entity(
				Coin {
					pos = {700, 240 + f32(rl.GetRandomValue(-128, 128))},
					radius = 12,
					collection_radius = 48,
				},
			)
			gs.coin_timer = gs.coin_time
		}

		// Move all coins
		for &e in Entities {
			if .alive in e.flags {
				if coin, ok := &e.type.(Coin); ok {
					player := &get_entity(gs.player_handle).type.(Player)

					coin.pos.x -= (150 * gs.game_speed) * dt

					// Check collision for coin follow
					if rl.CheckCollisionCircles(
						coin.pos,
						coin.collection_radius,
						player.pos,
						player.radius,
					) {
						coin.pos = linalg.lerp(coin.pos, player.pos, 0.3)
					}

					// Check player collision
					if rl.CheckCollisionCircles(coin.pos, coin.radius, player.pos, player.radius) {
						e.flags += {.dead}
					}

					// Delete off screen
					if coin.pos.x <= -coin.radius {
						e.flags += {.dead}
					}
				}
			}
		}
	}

	{ 	// Update Player
		player := &get_entity(gs.player_handle).type.(Player)
		player.vel.y += player.gravity
		if rl.IsKeyDown(.SPACE) {
			player.vel.y -= player.thrust
		}
		// Clamp Velocity
		player.vel.y = linalg.clamp(player.vel.y, -player.max_speed, player.max_speed)
		player.pos += player.vel * dt

		// Clamp to screen bounds
		if player.pos.y <= player.radius {
			player.pos.y = player.radius
			player.vel.y = 0
		} else if player.pos.y >= 480 - player.radius {
			player.pos.y = 480 - player.radius
			player.vel.y = 0
		}
	}

	// Increase game speed as game progresses
	gs.game_speed += 0.01 * dt
}

DRAW :: proc() {
	rl.ClearBackground(rl.BLACK)
	{ 	// Draw coins
		for &e in Entities {
			if .alive in e.flags {
				if coin, ok := e.type.(Coin); ok {
					rl.DrawCircleV(coin.pos, coin.radius, rl.YELLOW)
					rl.DrawCircleLinesV(coin.pos, coin.collection_radius, rl.RED)
				}
			}
		}
	}

	{ 	// Draw Player
		player := get_entity(gs.player_handle).type.(Player)
		rl.DrawCircleV(player.pos, player.radius, rl.GREEN)
	}

	{ 	// Debug UI
		rl.GuiLabel({2, 2, 64, 16}, rl.TextFormat("Entities: %i", living_entities))
		rl.DrawText(rl.TextFormat("Game Speed: %f", gs.game_speed), 2, 18, 16, rl.GREEN)
	}
}

UNLOAD :: proc() {}
