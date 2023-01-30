const std = @import("std");
const rl = @import("raylib");
const rmath = @import("raylib-math");

const gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const print = std.debug.print;

const width = 800;
const height = 800;

const Boid = struct {
    pos: rl.Vector2 = rl.Vector2{ 0, 0 },
    vel: rl.Vector2 = rl.Vector2{ 1, 1 },
    acc: rl.Vector2 = rl.Vector2{ 0, 0 },

    fn draw(self: *Boid) void {
        const velAngle = std.math.atan2(self.vel.y, self.vel.x);

        const angleDelta = comptime std.math.pi / 6;

        const angleLeft = velAngle - angleDelta;
        const angleRight = velAngle + angleDelta;

        const vec0 = rmath.Vector2Add(rl.Vector2{ .x = 10, .y = 0 }, self.pos);

        const vecLeft = rmath.Vector2Rotate(vec0, angleLeft);
        const vecRight = rmath.Vector2Rotate(vec0, angleRight);

        rl.DrawTriangle(self.pos, vecLeft, vecRight);
    }
};

pub fn main() !void {
    defer _ = gpa.deinit();

    var boids = std.ArrayList(Boid).init(allocator);
    defer boids.deinit();

    boids.append(Boid{});

    rl.InitWindow(width, height, "Boids");
    defer rl.CloseWindow();

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.BLACK);

        rl.DrawText("Hello world!", 100, 100, 20, rl.RAYWHITE);

        for (boids) |boid| {
            boid.draw();
        }
    }
}
