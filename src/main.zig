const std = @import("std");
const rl = @import("raylib");
const rlm = @import("raylib-math");

const print = std.debug.print;

const width = 800;
const height = 800;

const boidCount = 1;

const Boid = struct {
    pos: rl.Vector2 = rl.Vector2{ .x = width / 2, .y = height / 2 },
    vel: rl.Vector2 = rl.Vector2{ .x = 1, .y = 1 },
    acc: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },

    fn draw(self: *Boid) void {
        const velAngle = std.math.atan2(f32, self.vel.y, self.vel.x);

        const angleDelta = comptime (std.math.pi / 6.0);

        const angleLeft = velAngle - angleDelta;
        const angleRight = velAngle + angleDelta;

        const vec0 = rlm.Vector2Add(rl.Vector2{ .x = 10, .y = 0 }, self.pos);

        const vecLeft = rlm.Vector2Rotate(vec0, angleLeft);
        const vecRight = rlm.Vector2Rotate(vec0, angleRight);

        rl.DrawTriangle(self.pos, vecLeft, vecRight, rl.WHITE);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer _ = gpa.deinit();

    // var boids = try allocator.alloc(Boid, boidCount);
    // defer allocator.free(boids);

    var boids = std.ArrayList(Boid).init(allocator);
    defer boids.deinit();

    {
        var i: usize = 0;
        while (i < boidCount) : (i += 1) {
            try boids.append(Boid{});
        }
    }

    rl.InitWindow(width, height, "Boids");
    defer rl.CloseWindow();

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.BLACK);

        rl.DrawText("Hello world!", 100, 100, 20, rl.RAYWHITE);

        // var i: usize = 0;
        // while (i < boidCount) : (i += 1) {
        //     boids.toOwnedSlice()[i].draw();
        // }

        // var boidIter = std.mem.TokenIterator(boids.items);
        for (boids.toOwnedSlice()) |boid| {
            boid.draw();
        }
    }
}
