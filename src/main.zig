const std = @import("std");
const rl = @import("raylib");
const print = std.debug.print;

const width = 800;
const height = 800;

pub fn main() !void {
    rl.InitWindow(width, height, "Boids");
    defer rl.CloseWindow();

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.BLACK);

        rl.DrawText("Hello world!", 100, 100, 20, rl.RAYWHITE);
    }
}
