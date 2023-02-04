const std = @import("std");
const rl = @import("raylib");
const rlm = @import("raylib-math");

const print = std.debug.print;
const rand = std.crypto.random;

const width = 800;
const height = 800;

const boidCount = 100;

const Boid = struct {
    const boidRadius = 5;
    const boidPointerLen = 10;
    const boidSightDist = 30;
    const boidSightDistSqr = boidSightDist * boidSightDist;

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

    fn distanceToSqr(self: *Boid, friend: *const Boid) f32 {
        return rlm.Vector2DistanceSqr(self.pos, friend.pos);
    }

    fn findInRange(self: *Boid, others: []Boid, allocator: std.mem.Allocator) !std.ArrayList(*Boid) {
        var inRange = std.ArrayList(*Boid).init(allocator);

        for (others) |*other| {
            if (self.distanceToSqr(other) <= boidSightDistSqr) {
                try inRange.append(other);
            }
        }

        return inRange;
    }

    fn heading(self: *Boid) rl.Vector2 {
        return rlm.Vector2Normalize(self.vel);
    }

    fn alignTo(self: *Boid, others: []*Boid) void {
        var steering = rl.Vector2{ .x = 0, .y = 0 };

        for (others) |other| {
            steering = rlm.Vector2Add(steering, other.heading());
        }

        if (others.len > 0) {
            steering = rlm.Vector2Scale(steering, (1.0 / @intToFloat(f32, others.len)));
            steering = rlm.Vector2Subtract(steering, self.vel);

            self.acc = rlm.Vector2Add(self.acc, steering);
        }
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
        try boids.append(Boid{ .pos = rl.Vector2{ .x = @intToFloat(f32, rand.intRangeAtMost(i32, 0, width)), .y = @intToFloat(f32, rand.intRangeAtMost(i32, 0, height)) }, .vel = rlm.Vector2Rotate(rl.Vector2{ .x = 1, .y = 0 }, rand.float(f32) * std.math.pi * 2) });
    }

    rl.InitWindow(width, height, "Boids");
    defer rl.CloseWindow();

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        for (boids.items) |*boid| {
            var inRange = try boid.findInRange(boids.items, allocator);
            defer inRange.deinit();

            boid.alignTo(inRange.items);

            boid.update();
        }

        { // Do the drawing
            rl.BeginDrawing();
            defer rl.EndDrawing();

            rl.ClearBackground(rl.BLACK);

            for (boids.items) |*boid| {
                boid.draw();
            }
        }
    }
}
