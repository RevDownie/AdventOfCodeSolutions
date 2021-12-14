const std = @import("std");
const io = std.io;
const fs = std.fs;

const grid_width: u32 = 100;
const grid_area = grid_width * grid_width;
const grid_width_with_border = grid_width + 2;
const grid_area_with_border = grid_width_with_border * grid_width_with_border;

/// Advent of code - Day 9
///
/// Part 1 - Find all heights in the heightmap that are surrounded by higher points on the cardinal axes (i.e. bowls)
///
pub fn main() !void {
    const input_file = try fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    //Using my knowledge of the file size and length to define the buffer sizes
    var input_buffer: [1024 * 10]u8 = undefined;
    const input_len = try input_file.readAll(&input_buffer);

    const stdout = std.io.getStdOut().writer();
    const timer = std.time.Timer;
    const t = try timer.start();

    const heightmap = build_heightmap(input_buffer[0..input_len]);
    const result_1 = find_bowls_total_risk_level(heightmap[0..]);
    const result_2 = 0;
    try stdout.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Convert the raw data to a grid and put a border round it to remove the need for bounds checks
///
fn build_heightmap(input_buffer: []u8) [grid_area_with_border]u8 {
    var hm = [_]u8{255} ** grid_area_with_border;
    var hm_idx = grid_width_with_border + 1;
    var inner_count: u32 = 0;
    for (input_buffer) |c| {
        if (c != '\n') {
            hm[hm_idx] = c - '0';
            hm_idx += 1;
            inner_count += 1;

            if (inner_count == grid_width) {
                hm_idx += 2;
                inner_count = 0;
            }
        }
    }

    return hm;
}

fn find_bowls_total_risk_level(heightmap: []const u8) u32 {
    var total_risk: u32 = 0;
    var i = grid_width_with_border + 1;
    const end = heightmap.len - grid_width_with_border - 1;
    while (i < end) : (i += 1) {
        const l = i - 1;
        const r = i + 1;
        const u = i - grid_width_with_border;
        const d = i + grid_width_with_border;
        const h = heightmap[i];

        if (heightmap[l] > h and heightmap[r] > h and heightmap[u] > h and heightmap[d] > h) {
            total_risk += 1 + h;
        }
    }

    return total_risk;
}
