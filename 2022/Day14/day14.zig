const std = @import("std");

const input_file = @embedFile("input.txt");

//I really should calculate these based on the amount of fall off room required but just hard coding them based on the input data
const GRID_WIDTH = 500;
const GRID_HEIGHT = 180;
const GRID_WIDTH_OFFSET = 300; //All coords are up around ~500 so wastes alot of space in the array - this just slides it forward

/// Advent of code - Day 14
///
/// Part 1 - Plot the rocks on a grid and then particle deposition sand until no more come to rest
/// Part 2 - Add a floor and perform the particle deposition until the sand blocks the opening
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    var highest_y: u32 = 0;
    var grid_1 = try buildStartingGrid(input_file[0..], &highest_y);
    const result_1 = sandSimulation(&grid_1, 500 - GRID_WIDTH_OFFSET);

    var grid_2 = try buildStartingGrid(input_file[0..], &highest_y);
    //Add floor
    var x: u32 = 0;
    while (x < GRID_WIDTH) : (x += 1) {
        grid_2.set((highest_y + 2) * GRID_WIDTH + x);
    }
    const result_2 = sandSimulation(&grid_2, 500 - GRID_WIDTH_OFFSET);

    std.debug.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Parse the input of straight line segments and fill them in as rock in the grid
/// Path is formatted as 498,4 -> 498,6 -> 496,6
///
fn buildStartingGrid(data: []const u8, highest_y: *u32) !std.StaticBitSet(GRID_WIDTH * GRID_HEIGHT) {
    var grid = std.StaticBitSet(GRID_WIDTH * GRID_HEIGHT).initEmpty();

    var line_it = std.mem.tokenize(u8, data, "\n");
    while (line_it.next()) |line| {
        var i: usize = 0;
        var j: usize = 0;

        var last_x_opt: ?u32 = null;
        var last_y: u32 = undefined;

        while (true) {
            //Skip to the start of the next digit or finish if we reach the end
            while (i < line.len and isDigit(line[i]) == false) : (i += 1) {}
            if (i >= line.len) {
                break;
            }
            j = i;

            //Read the X co-ord
            while (isDigit(line[j])) : (j += 1) {}
            const x = try std.fmt.parseUnsigned(u32, line[i..j], 10);
            i = j + 1;
            j = i;

            //Read the Y co-ord
            while (j < line.len and isDigit(line[j])) : (j += 1) {}
            const y = try std.fmt.parseUnsigned(u32, line[i..j], 10);
            i = j + 1;
            j = i;

            highest_y.* = std.math.max(highest_y.*, y);

            //Try fill in the line between points
            if (last_x_opt) |last_x| {
                if (last_y == y) {
                    //Fill x
                    var xmin = std.math.min(last_x, x);
                    var xmax = std.math.max(last_x, x);
                    while (xmin <= xmax) : (xmin += 1) {
                        const idx = (y * GRID_WIDTH + xmin) - GRID_WIDTH_OFFSET;
                        grid.set(idx);
                    }
                } else {
                    //Fill y
                    var ymin = std.math.min(last_y, y);
                    var ymax = std.math.max(last_y, y);
                    while (ymin <= ymax) : (ymin += 1) {
                        const idx = (ymin * GRID_WIDTH + x) - GRID_WIDTH_OFFSET;
                        grid.set(idx);
                    }
                }
            }

            last_x_opt = x;
            last_y = y;
        }
    }

    return grid;
}

/// Deposit a particle of sand at 500,0 and have it fall until it comes to rest and then deposit another
/// The next sand particle falls once the previous has come to rest
/// Sand falls down first, then down to the left and then down to the right
/// We stop the simulation once there is:
///    1. no more sand coming to rest
///    2. blocked the 500,0 opening
/// and return the number of deposits to get to those states
///
fn sandSimulation(grid: *std.StaticBitSet(GRID_WIDTH * GRID_HEIGHT), start_x: i32) u32 {
    var ticks: u32 = 0;

    var n: u32 = 0;
    while (true) : (n += 1) {
        var y: i32 = 0;
        var x: i32 = start_x;
        while (true) {
            //Try down first
            const y_down = y + 1;
            if (y_down >= GRID_HEIGHT) {
                return ticks;
            }
            const idx_down = @intCast(u32, y_down * GRID_WIDTH + x);
            if (grid.isSet(idx_down) == false) {
                y = y_down;
                continue;
            }

            //Next try down and to the left
            const x_left = x - 1;
            if (x_left < 0) {
                return ticks;
            }
            const idx_downleft = @intCast(u32, y_down * GRID_WIDTH + x_left);
            if (grid.isSet(idx_downleft) == false) {
                y = y_down;
                x = x_left;
                continue;
            }

            //Next try down and to the right
            const x_right = x + 1;
            if (x_right >= GRID_WIDTH) {
                return ticks;
            }
            const idx_downright = @intCast(u32, y_down * GRID_WIDTH + x_right);
            if (grid.isSet(idx_downright) == false) {
                y = y_down;
                x = x_right;
                continue;
            }

            //Nowhere else to go - just come to rest and start the next deposit
            const idx = @intCast(u32, y * GRID_WIDTH + x);
            grid.set(idx);
            ticks += 1;

            if (x == start_x and y == 0) {
                //Blocked the opening
                return ticks;
            }

            break;
        }
    }

    return ticks;
}

/// Return true if it is an ASCII digit between 0-9
///
inline fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}
