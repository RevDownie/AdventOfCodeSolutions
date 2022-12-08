const std = @import("std");

const input_file = @embedFile("input.txt");

const GRID_DIMS = 99;

/// Advent of code - Day 8
///
/// Part 1 - Find all the trees that are visible from outside the grid
/// Part 2 - ???
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const result_1 = findVisibleTrees(input_file[0..]);
    const result_2 = 0;

    std.debug.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// For each row and column walk along it forwards tracking the current tallest tree and counting any less than the current tallest
/// Then walk rows and columns in reverse doing the same but stopping when we reach the tallest tree
/// No need to convert from ASCII as the values are relative
///
fn findVisibleTrees(data: []const u8) usize {
    var largest_top = [_]usize{0} ** GRID_DIMS;
    var largest_left = [_]usize{0} ** GRID_DIMS;
    var visible_set = std.StaticBitSet((GRID_DIMS + 1) * GRID_DIMS).initEmpty();

    //Walk top down
    {
        var x: usize = 0;
        while (x < GRID_DIMS) : (x += 1) {
            var y: usize = 0;
            while (y < GRID_DIMS) : (y += 1) {
                const idx = y * (GRID_DIMS + 1) + x;
                if (data[idx] > largest_top[x]) {
                    largest_top[x] = data[idx];
                    visible_set.set(idx);
                }
            }
        }
    }

    //Walk bottom-up, we can stop at the known largest
    {
        var x: usize = 0;
        while (x < GRID_DIMS) : (x += 1) {
            var largest_height: usize = 0;
            var y: isize = GRID_DIMS - 1;
            while (y >= 0) : (y -= 1) {
                const idx = @intCast(usize, y) * (GRID_DIMS + 1) + x;
                if (data[idx] > largest_height) {
                    largest_height = data[idx];
                    visible_set.set(idx);
                }

                if (data[idx] == largest_top[x]) {
                    break;
                }
            }
        }
    }

    //Walk left right
    {
        var y: usize = 0;
        while (y < GRID_DIMS) : (y += 1) {
            var x: usize = 0;
            while (x < GRID_DIMS) : (x += 1) {
                const idx = y * (GRID_DIMS + 1) + x;
                if (data[idx] > largest_left[y]) {
                    largest_left[y] = data[idx];
                    visible_set.set(idx);
                }
            }
        }
    }

    //Walk right-left, we can stop at the known largest
    {
        var y: usize = 0;
        while (y < GRID_DIMS) : (y += 1) {
            var largest_height: usize = 0;
            var x: isize = GRID_DIMS - 1;
            while (x >= 0) : (x -= 1) {
                const idx = y * (GRID_DIMS + 1) + @intCast(usize, x);
                if (data[idx] > largest_height) {
                    largest_height = data[idx];
                    visible_set.set(idx);
                }

                if (data[idx] == largest_top[y]) {
                    break;
                }
            }
        }
    }

    return visible_set.count();
}
