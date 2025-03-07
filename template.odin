package main

import "core:math"
import rl "vendor:raylib"

GAME_WIDTH :: 640
GAME_HEIGHT :: 480

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_RESIZABLE})
	rl.InitWindow(GAME_WIDTH, GAME_HEIGHT, "TEMPLATE")
	defer rl.CloseWindow()

	render_target := rl.LoadRenderTexture(640, 480)
	defer rl.UnloadRenderTexture(render_target)

	LOAD()
	defer UNLOAD()

	for !rl.WindowShouldClose() {
		scale := min(
			f32(rl.GetScreenWidth()) / f32(GAME_WIDTH),
			f32(rl.GetScreenHeight()) / f32(GAME_HEIGHT),
		)
		rl.SetMouseOffset(
			i32(-(f32(rl.GetScreenWidth()) - (f32(GAME_WIDTH) * scale)) * 0.5),
			i32(-(f32(rl.GetScreenHeight()) - (f32(GAME_HEIGHT) * scale)) * 0.5),
		)
		rl.SetMouseScale(1 / scale, 1 / scale)

		UPDATE(rl.GetFrameTime())

		rl.BeginTextureMode(render_target)
		rl.ClearBackground(rl.BLACK)
		DRAW()
		rl.EndTextureMode()

		// Draw scaled texture
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		rl.DrawTexturePro(
			render_target.texture,
			{0, 0, f32(render_target.texture.width), -(f32(render_target.texture.height))},
			{
				(f32(rl.GetScreenWidth()) - (f32(GAME_WIDTH) * scale)) * 0.5,
				(f32(rl.GetScreenHeight()) - (f32(GAME_HEIGHT) * scale)) * 0.5,
				f32(GAME_WIDTH) * scale,
				f32(GAME_HEIGHT) * scale,
			},
			{0, 0},
			0.0,
			rl.WHITE,
		)
		rl.EndDrawing()
	}
}
