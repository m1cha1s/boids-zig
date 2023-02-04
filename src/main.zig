const std = @import("std");
const rl = @import("raylib");
const rlm = @import("raylib-math");

const print = std.debug.print;

const width = 800;
const height = 800;

const boidCount = 1;

const Boid = struct {
    const boidRadius = 5;
    const boidPointerLen = 10;

    pos: rl.Vector2 = rl.Vector2{ .x = width / 2, .y = height / 2 },
    vel: rl.Vector2 = rl.Vector2{ .x = 1, .y = 1 },
    acc: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },

    fn draw(self: *Boid) void {
        const velAngle = std.math.atan2(f32, self.vel.y, self.vel.x);

        rl.DrawLineV(self.pos, rl.Vector2{ .x = (std.math.cos(velAngle) * boidPointerLen) + self.pos.x, .y = (std.math.sin(velAngle) * boidPointerLen) + self.pos.y }, rl.RAYWHITE);

        rl.DrawCircleV(self.pos, boidRadius, rl.RAYWHITE);
    }

    fn wrap(self: *Boid) void {
        if (self.pos.x < 0) self.pos.x += width;
        if (self.pos.x >= width) self.pos.x -= width;

        if (self.pos.y < 0) self.pos.y += height;
        if (self.pos.y >= height) self.pos.y -= height;
    }

    fn update(self: *Boid) void {
        self.vel = rlm.Vector2Add(self.vel, self.acc);
        self.pos = rlm.Vector2Add(self.pos, self.vel);

        self.wrap();

        self.acc.x = 0;
        self.acc.y = 0;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer _ = gpa.deinit();

    var boids = std.ArrayList(Boid).init(allocator);
    defer boids.deinit();

    var i: usize = 0;
    while (i < boidCount) : (i += 1) {
        try boids.append(Boid{});
    }

    rl.InitWindow(width, height, "Boids");
    defer rl.CloseWindow();

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        for (boids.items) |*boid| {
            boid.update();
        }

        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.BLACK);

        rl.DrawText("Hello world!", 100, 100, 20, rl.RAYWHITE);

        for (boids.items) |*boid| {
            boid.draw();
        }
    }
}
