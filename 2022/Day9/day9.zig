const std = @import("std");
const math = std.math;
const Vec2 = @Vector(2, i16);

const input_file = @embedFile("input.txt");

/// Advent of code - Day 9
///
/// NOTE: DOES NOT WORK - Hash set seems to return incorrect count - even for custom packed u32 key
///
/// Part 1 - Knots in a rope. Keep the tail next to the head and count visited spaces
/// Part 2 - The rope is now 10 in length
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const result_1 = try runSimulation(input_file[0..], gpa.allocator(), 2);
    const result_2 = try runSimulation(input_file[0..], gpa.allocator(), 10);

    std.debug.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Knots start at the same location
/// Parse the instructions for how the head moves "R 5", "U 2", etc
/// Move head to the location and have the below knots move to within one and mark any travelled positions as visited
/// knot won't move if it is within 1 even diagnonally but if it does move won't ever rest diagonally
///     - so if it is in a different row or col it's first move will be diagonally
///
fn runSimulation(data: []const u8, allocator: std.mem.Allocator, comptime rope_len: u32) !usize {
    var knot_positions = [_]Vec2{Vec2{ 0, 0 }} ** rope_len;
    var visited_set = std.AutoHashMap(Vec2, void).init(allocator);
    defer visited_set.deinit();

    var lines = std.mem.tokenize(u8, data, "\n");
    while (lines.next()) |line| {
        const dir = line[0];
        const steps = line[2] - '0';

        const v = switch (dir) {
            'R' => Vec2{ 1, 0 },
            'L' => Vec2{ -1, 0 },
            'U' => Vec2{ 0, 1 },
            'D' => Vec2{ 0, -1 },
            else => @panic("Unknown Dir"),
        };

        var i: u8 = 0;
        while (i < steps) : (i += 1) {
            //Move head to the next location
            knot_positions[0] += v;

            //Move all the knots below the head
            var k: usize = 1;
            while (k < rope_len) : (k += 1) {
                //Check if we need to move the tail
                const delta = knot_positions[k - 1] - knot_positions[k];
                if (try math.absInt(delta[0]) <= 1 and try math.absInt(delta[1]) <= 1) {
                    continue;
                }

                //Move the tail
                knot_positions[k] += Vec2{ math.sign(delta[0]), math.sign(delta[1]) };
            }

            //Record unique tail positions
            try visited_set.put(knot_positions[rope_len - 1], {});
        }
    }

    return visited_set.count() + 1; //Including the start pos
}
