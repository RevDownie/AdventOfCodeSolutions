const std = @import("std");
const io = std.io;
const fs = std.fs;

const grid_dims: u32 = 1000;
const grid_area: u32 = grid_dims * grid_dims;

/// Advent of code - Day 5
///
/// Part 1 - Find the grid cells where lines intersect at least once - only horizontal/vertical
/// Part 2 - Part 1 but with 45 degree diagonals too
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
    const result_1 = count_overlaps_cardinal_pipes(false, input_buffer[0..input_len]);
    const result_2 = count_overlaps_cardinal_pipes(true, input_buffer[0..input_len]);
    try stdout.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

fn count_overlaps_cardinal_pipes(comptime include_diags: bool, input_buffer: []u8) !usize {
    //Track first and second hits as we need to identify any with 2 or more intersections
    var grid_hit_1 = std.StaticBitSet(grid_area).initEmpty();
    var grid_hit_2 = std.StaticBitSet(grid_area).initEmpty();

    var i: usize = 0;
    var num_idx: u32 = 0;
    var pairs: [4]u32 = undefined;
    while (i < input_buffer.len - 1) {
        //Parse the pairs of co-ords
        while (input_buffer[i] < '0' or input_buffer[i] > '9') : (i += 1) {} //Skip to the start of the number
        var j: usize = i;
        while (input_buffer[j] >= '0' and input_buffer[j] <= '9') : (j += 1) {} //Skip to the end of the number
        pairs[num_idx] = try std.fmt.parseUnsigned(u32, input_buffer[i..j], 10);
        i = j + 1;
        num_idx += 1;

        //We have a start and end coord - walk the line marking grid cells that we cross
        if (num_idx == 4) {
            num_idx = 0;

            if (include_diags == false and pairs[0] != pairs[2] and pairs[1] != pairs[3]) {
                continue;
            }

            walk_the_line(@TypeOf(grid_hit_1), pairs[0], pairs[1], pairs[2], pairs[3], &grid_hit_1, &grid_hit_2);
        }
    }

    return grid_hit_2.count();
}

fn walk_the_line(comptime T: type, x1: u32, y1: u32, x2: u32, y2: u32, grid_hit_1: *T, grid_hit_2: *T) void {
    var xstart = @intCast(i32, x1);
    var xend = @intCast(i32, x2);
    var ystart = @intCast(i32, y1);
    var yend = @intCast(i32, y2);

    const xdt = xend - xstart;
    const ydt = yend - ystart;
    const xdir = sign(xdt);
    const ydir = sign(ydt);
    const num_steps = std.math.max(xdt * xdir, ydt * ydir); //45 degrees so don't need to worry about different steps

    var step: u32 = 0;
    while (step <= num_steps) : ({
        step += 1;
        xstart += xdir;
        ystart += ydir;
    }) {
        const index = @intCast(u32, ystart * grid_dims + xstart);
        if (grid_hit_1.isSet(index)) {
            grid_hit_2.set(index);
        } else {
            grid_hit_1.set(index);
        }
    }
}

fn sign(a: i32) i32 {
    if (a == 0) {
        return 0;
    }
    if (a > 0) {
        return 1;
    }
    return -1;
}
