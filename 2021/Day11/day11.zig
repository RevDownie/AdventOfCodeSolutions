const std = @import("std");
const io = std.io;
const fs = std.fs;

const grid_width: u32 = 10;
const grid_area = grid_width * grid_width;

/// Advent of code - Day 11
///
/// Part 1 - Run 100 simulations ticking the timer on each cell, when it reaches 10 it flashes and resets, flashes cause adjacent cells to increase
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

    var grid = create_grid(input_buffer[0..input_len]);

    const result_1 = simulate_ticks(100, &grid);
    const result_2 = 0;
    try stdout.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

fn create_grid(input_buffer: []u8) [grid_area]u8 {
    var grid: [grid_area]u8 = undefined;
    var i: usize = 0;
    for (input_buffer) |c| {
        if (c == '\n') {
            continue;
        }

        grid[i] = c - '0';
        i += 1;
    }

    return grid;
}

/// Tick and count the number of flashes
///
fn simulate_ticks(num_ticks: u32, energies: *[grid_area]u8) u32 {
    var num_flashes: u32 = 0;

    var tick: u32 = 0;
    while (tick < num_ticks) : (tick += 1) {
        var to_flash: [grid_area]usize = undefined;
        var to_flash_head: usize = 0;
        var has_flashed = std.StaticBitSet(grid_area).initEmpty();

        //Increase the enery of all in the first pass and track ones that need flashed
        for (energies) |*energy, i| {
            energy.* += 1;
            if (energy.* > 9) {
                to_flash[to_flash_head] = i;
                to_flash_head += 1;
                has_flashed.set(i);
            }
        }

        //Keep going while the flashes are cascading
        while (to_flash_head > 0) {
            to_flash_head -= 1;
            const i = to_flash[to_flash_head];

            const adjacent_idxs = calculate_adjacent_indices(i);
            for (adjacent_idxs) |ai| {
                if (ai >= grid_area) {
                    continue;
                }

                energies[ai] += 1;
                if (energies[ai] > 9 and has_flashed.isSet(ai) == false) {
                    to_flash[to_flash_head] = ai;
                    to_flash_head += 1;
                    has_flashed.set(ai);
                }
            }
        }

        //Reset any that flashed
        for (energies) |*energy| {
            if (energy.* > 9) {
                energy.* = 0;
                num_flashes += 1;
            }
        }
    }

    return num_flashes;
}

fn calculate_adjacent_indices(i: usize) [8]usize {
    var adjacent_idxs: [8]usize = undefined;

    const x = i % grid_width;
    const y = i / grid_width;

    adjacent_idxs[0] = if (x > 0) y * grid_width + (x - 1) else grid_area; //L
    adjacent_idxs[1] = if (x < grid_width - 1) y * grid_width + (x + 1) else grid_area; //R
    adjacent_idxs[2] = if (y > 0) (y - 1) * grid_width + x else grid_area; //U
    adjacent_idxs[3] = if (y < grid_width - 1) (y + 1) * grid_width + x else grid_area; //D
    adjacent_idxs[4] = if (x > 0 and y > 0) (y - 1) * grid_width + (x - 1) else grid_area; //LU
    adjacent_idxs[5] = if (x < grid_width - 1 and y > 0) (y - 1) * grid_width + (x + 1) else grid_area; //RU
    adjacent_idxs[6] = if (x > 0 and y < grid_width - 1) (y + 1) * grid_width + (x - 1) else grid_area; //LD
    adjacent_idxs[7] = if (x < grid_width - 1 and y < grid_width - 1) (y + 1) * grid_width + (x + 1) else grid_area; //RD

    return adjacent_idxs;
}
