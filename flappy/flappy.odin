package main

import "core:math/linalg"
import rl "vendor:raylib"

GAME_TITLE :: "Flappy Fish"
GAME_WIDTH :: 640
GAME_HEIGHT :: 480

GameState :: struct {
	player:      struct {
		pos:        [2]f32,
		vel:        f32,
		flap_speed: f32,
		gravity:    f32,
		radius:     f32,
	},
	pipes:       [3]struct {
		top:    rl.Rectangle,
		bottom: rl.Rectangle,
		pos:    [2]f32,
	},
	game_speed:  f32,
	pipe_speed:  f32,
	pipe_gap:    f32,
	pipe_spread: f32,
	pipe_width:  f32,
}
gs: GameState

LOAD :: proc() {
	//:init gamestate
	gs = GameState {
		player = {pos = {128, 240}, gravity = 980, flap_speed = 250, radius = 12},
		game_speed = 1,
		pipe_speed = 90,
		pipe_gap = 64,
		pipe_spread = 300,
		pipe_width = 80,
	}

	//:init pipes
	for &pipe, i in gs.pipes {
		pipe.pos = {(700 + (f32(i) * gs.pipe_spread)), 240 + f32(rl.GetRandomValue(-128, 128))}
	}
}

UPDATE :: proc(dt: f32) {
	//:update player
	gs.player.vel += gs.player.gravity * dt
	if rl.IsKeyPressed(.SPACE) {
		gs.player.vel = -gs.player.flap_speed
	}
	gs.player.pos.y += gs.player.vel * dt

	for &pipe in gs.pipes {
		pipe.pos.x -= (gs.pipe_speed * gs.game_speed) * dt

		// wrap pipe (lol)
		// NOTE: Need to find a way to keep the gap consistent.
		if pipe.pos.x < -gs.pipe_width {
			pipe.pos.x = 700
			pipe.pos.y = 240 + f32(rl.GetRandomValue(-128, 128))
		}

		pipe.top = {pipe.pos.x, 0, gs.pipe_width, pipe.pos.y - gs.pipe_gap}
		pipe.bottom = {pipe.pos.x, pipe.pos.y + gs.pipe_gap, gs.pipe_width, 400}
	}
	gs.game_speed += 0.01 * dt
}

DRAW :: proc() {
	rl.ClearBackground(rl.BLACK)

	//:draw pipes
	for pipe in gs.pipes {
		rl.DrawRectangleRec(pipe.top, rl.GREEN)
		rl.DrawRectangleRec(pipe.bottom, rl.GREEN)
	}

	//:draw player
	rl.DrawCircleV(gs.player.pos, gs.player.radius, rl.YELLOW)

	rl.DrawText(rl.TextFormat("game_speed: %f", gs.game_speed), 2, 2, 15, rl.RED)
}

UNLOAD :: proc() {

}
