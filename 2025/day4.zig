const std = @import("std");

const input_file = @embedFile("input_day4.txt");

const dir = @Vector(2, i32);

/// Advent of code - Day 4
///
/// Part 1 - Count the "rolls of paper that can be removed" e.g. that have fewer than 4 other rolls in adjacent squares
/// Part 2 - Keep running the simulation removing rolls until there are none left to remove. Count the rolls removed
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const result = try simulate(input_file[0..], gpa.allocator());
    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result.p1, result.p2, duration / 1000000.0 });
}

/// 2 phases:
/// first phase completes part 1 and also counts the neighbours of each roll
/// second phase runs the simulation until it stabilises - reducing the neighbour count of each removed roll
///
fn simulate(data: []const u8, allocator: std.mem.Allocator) !struct { p1: u32, p2: u32 } {
    var neighbour_counts_grid = try allocator.alloc(i32, data.len);
    @memset(neighbour_counts_grid, 0);
    defer allocator.free(neighbour_counts_grid);

    var open_set = try std.ArrayList(usize).initCapacity(allocator, 100);
    defer open_set.deinit(allocator);

    const stride = std.mem.indexOfScalar(u8, data, '\n').? + 1; //Account for the newline in the data
    const neighbour_dirs = [8]dir{ dir{ 1, 0 }, dir{ 0, 1 }, dir{ -1, 0 }, dir{ 0, -1 }, dir{ 1, 1 }, dir{ -1, -1 }, dir{ 1, -1 }, dir{ -1, 1 } };

    //Count the number of neighbours of each roll by checking adjacent cells
    var total1: u32 = 0;
    for (data, 0..) |c, i| {
        if (c != '@') {
            continue;
        }

        const pos = dir{ @intCast(i % stride), @intCast(i / stride) };
        var neighbours: i32 = 0;
        for (neighbour_dirs) |d| {
            const npos = pos + d;
            if (npos[0] >= 0 and npos[0] < stride - 1 and npos[1] >= 0 and npos[1] < stride - 1) {
                const x: usize = @intCast(npos[0]);
                const y: usize = @intCast(npos[1]);
                const ni = y * stride + x;
                if (data[ni] == '@') {
                    neighbours += 1;
                }
            }
        }

        neighbour_counts_grid[i] = neighbours;

        //Part 1
        if (neighbours < 4) {
            total1 += 1;
            //Seed the open list of rolls to explore in the next pass
            try open_set.append(allocator, i);
        }
    }

    //Start with the rolls we know can be removed. Run the simulation adding rolls to check there is no move rolls to remove.
    //Decrement the neighbour count of all adjacent rolls for any one we remove
    var total2: u32 = 0;
    while (open_set.pop()) |i| {
        if (neighbour_counts_grid[i] < 0) {
            continue;
        }

        //Remove this "roll"
        total2 += 1;
        neighbour_counts_grid[i] = -1;

        //Reduce the neighbour count of each around it
        const pos = dir{ @intCast(i % stride), @intCast(i / stride) };
        for (neighbour_dirs) |d| {
            const npos = pos + d;
            if (npos[0] >= 0 and npos[0] < stride - 1 and npos[1] >= 0 and npos[1] < stride - 1) {
                const x: usize = @intCast(npos[0]);
                const y: usize = @intCast(npos[1]);
                const ni = y * stride + x;
                if (neighbour_counts_grid[ni] >= 0) {
                    neighbour_counts_grid[ni] -= 1;

                    if (neighbour_counts_grid[ni] < 4) {
                        //Add this as a roll to remove next
                        try open_set.append(allocator, ni);
                    }
                }
            }
        }
    }

    return .{ .p1 = total1, .p2 = total2 };
}
