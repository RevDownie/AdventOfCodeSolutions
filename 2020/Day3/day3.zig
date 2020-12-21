const std = @import("std");
const io = std.io;
const fs = std.fs;

const Slope = struct {
    xstep: usize, ystep: usize
};

const slopes = [_]Slope{
    create_slope(1, 1),
    create_slope(3, 1),
    create_slope(5, 1),
    create_slope(7, 1),
    create_slope(1, 2),
};

/// Helper function to populate the array as Zig doesn't seem to support assigning directly in array
///
fn create_slope(xstep: usize, ystep: usize) Slope {
    return Slope{ .xstep = xstep, .ystep = ystep };
}

/// Advent of code - Day 3
///
/// Part 1 - Given a grid starting at the top-left go right 3 down 1 until you reach the bottom and count all the # symbols. The grid wraps left to right
/// Part 2 - Multiple slopes (not just 3-1 but 1-1, 5-1, 7-1, and 1-2). Count trees for each and multiply together
///
pub fn main() !void {
    const input_file = try fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    //Using my knowledge of the file size and length to define the buffer sizes
    var input_buffer: [11 * 1024]u8 = undefined;
    const input_len = try input_file.readAll(&input_buffer);

    const grid_width: usize = 31;
    const grid_len = remove_newlines(input_buffer[0..input_len], grid_width);
    const grid = input_buffer[0..grid_len];

    //Part 1 only requries a single slope
    const result_1 = count_trees(slopes[1], grid_width, grid_len, grid);

    //Part 2 requires all the slope results to be multiplied together
    var result_2: usize = 1;
    for (slopes) |slope| {
        const tree_count = count_trees(slope, grid_width, grid_len, grid);
        const stdout = std.io.getStdOut().writer();
        try stdout.print("{}\n", .{tree_count});
        result_2 *= tree_count;
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Part 1: {}, Part 2: {}\n", .{ result_1, result_2 });
}

/// Remove all the new lines to make the grid logic easier
/// Just shunts the values up and returns the new length
///
fn remove_newlines(data: []u8, width: usize) usize {
    var writeidx: usize = width;
    var readidx: usize = writeidx + 1;
    while (readidx < data.len) : (writeidx += width) {
        var j: usize = 0;
        while (j < width) : (j += 1) {
            data[writeidx + j] = data[readidx + j];
        }

        readidx += width + 1;
    }

    return data.len - (data.len / (width + 1));
}

/// Step the grid by x (wrapping) and y and count the trees (hashes) encountered
///
fn count_trees(slope: Slope, grid_width: usize, grid_len: usize, grid: []const u8) usize {
    var curr_x: usize = 0;
    var curr_y: usize = 0;
    var tree_count: usize = 0;

    //Walk the grid wrapping on X, stepping x and y each iteration and counting the hashes.
    while (true) {
        curr_x = (curr_x + slope.xstep) % grid_width;
        curr_y += slope.ystep;
        const curr_index = curr_x + grid_width * curr_y;
        if (curr_index >= grid_len) {
            break;
        }

        if (grid[curr_index] == '#') {
            tree_count += 1;
        }
    }

    return tree_count;
}
