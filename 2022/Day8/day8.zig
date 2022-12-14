const std = @import("std");

const input_file = @embedFile("input.txt");

const GRID_DIMS = 99;

/// Advent of code - Day 8
///
/// Part 1 - Find all the trees that are visible from outside the grid
/// Part 2 - Fiind the tree that can see furthest in cardinal directions
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const result_1 = findVisibleTrees(input_file[0..]);
    const result_2 = findTreeWithBestView(input_file[0..]);

    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
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


    //TODO: Should really skip the perimeter in the search and add it on at the end GRID_DIMS * 4 - 4
    return visible_set.count();
}

/// Find the tree with the best view - can see the furthest unimpeded in each direction
///
fn findTreeWithBestView(data: []const u8) isize {
    var scenic_scores = [_]isize{1} ** (GRID_DIMS * GRID_DIMS);

    var y: isize = 1;
    while (y < GRID_DIMS - 1) : (y += 1) {
        var x: isize = 1;
        while (x < GRID_DIMS - 1) : (x += 1) {
            const idx_curr = @intCast(usize, y * (GRID_DIMS + 1) + x);
            const height_curr = data[idx_curr];

            //Right
            var xr = x;
            while (xr < GRID_DIMS - 1) {
                xr += 1;
                const idx_check = @intCast(usize, y * (GRID_DIMS + 1) + xr);
                if (data[idx_check] >= height_curr) {
                    break;
                }
            }
            scenic_scores[idx_curr] *= (xr - x);

            //Left
            var xl = x - 1;
            while (xl > 0) : (xl -= 1) {
                const idx_check = @intCast(usize, y * (GRID_DIMS + 1) + xl);
                if (data[idx_check] >= height_curr) {
                    break;
                }
            }
            scenic_scores[idx_curr] *= (x - xl);

            //Up
            var yu = y - 1;
            while (yu > 0) : (yu -= 1) {
                const idx_check = @intCast(usize, yu * (GRID_DIMS + 1) + x);
                if (data[idx_check] >= height_curr) {
                    break;
                }
            }
            scenic_scores[idx_curr] *= (y - yu);

            //Down
            var yd = y;
            while (yd < GRID_DIMS - 1) {
                yd += 1;
                const idx_check = @intCast(usize, yd * (GRID_DIMS + 1) + x);
                if (data[idx_check] >= height_curr) {
                    break;
                }
            }
            scenic_scores[idx_curr] *= (yd - y);
        }
    }

    return std.mem.max(isize, scenic_scores[0..]);
}

