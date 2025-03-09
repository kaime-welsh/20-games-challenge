package main

import rl "vendor:raylib"

GAME_TITLE :: "Jetpack"
GAME_WIDTH :: 640
GAME_HEIGHT :: 480

// NOTE: Object pooling
// =========================
// PoolStruct
// - pool: [?]ObjectToPool
// - allocated_objects: int
// - GetObject => pop from end of array, push to front. allocated_objects += 1
// - KillObject => pop from front of array, push to back. allocated objects -= 1
// easy win
// 
// update:
// doesn't work unless dynamic array, unless I want to manually shift everything over.
// might be better to just use a flag & handle system like randy's, but simplify no need for a
// monolithic generic object struct tbh? idk we'll see.

LOAD :: proc() {}

UPDATE :: proc(dt: f32) {}

DRAW :: proc() {}

UNLOAD :: proc() {}
