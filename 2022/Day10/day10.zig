const std = @import("std");

const input_file = @embedFile("input.txt");

const InstructionType = enum {
    noop,
    addx,
};

const InstructionData = struct {
    type: InstructionType,
    value: isize,
    cycles: usize,
};

const SCREEN_WIDTH = 40;
const SCREEN_HEIGHT = 6;

/// Advent of code - Day 10
///
/// Part 1 - Run instructions that update a X register after a number of cycles and monitor the value after every 20 cycles and then every 40
/// Part 2 - X register corresponds to screen pos of a sprite
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    var screen = [_]u8{'.'} ** (SCREEN_WIDTH * SCREEN_HEIGHT);
    const result_1 = try runSimulation(input_file[0..], 20, 40, screen[0..]);

    std.debug.print("Part 1: {}, Part 2: See Below ms: {}\n", .{ result_1, @intToFloat(f64, t.read()) / 1000000.0 });

    var i: usize = 0;
    while (i < SCREEN_HEIGHT) : (i += 1) {
        const ymin = 40 * i;
        const ymax = ymin + 40;
        std.debug.print("{s}\n", .{screen[ymin..ymax]});
    }
}

/// noop takes 1 cycle does nothing
/// addx -9 takes 2 cycles and then adds the value to x
/// After N cycles multiply N by X and add to the total
///
/// Also turn on the screen pixels based on a pixel being drawn each cycle and the sprite mid pos controlled by x
///
fn runSimulation(data: []const u8, comptime offset: u32, comptime n: u32, screen: []u8) !isize {
    var total: isize = 0;
    var x: isize = 1;
    var total_cycles: usize = 0;

    var lines = std.mem.tokenize(u8, data, "\n");
    while (lines.next()) |line| {
        const next_instruction = try parseInstruction(line);

        var instruction_cycle_counter: usize = 0;
        while (instruction_cycle_counter < next_instruction.cycles) : (instruction_cycle_counter += 1) {
            const pos = total_cycles % SCREEN_WIDTH;
            if (pos >= x - 1 and pos <= x + 1) {
                screen[total_cycles] = '#';
            }

            total_cycles += 1;

            if (total_cycles == offset or (total_cycles + offset) % n == 0) {
                total += @intCast(isize, total_cycles) * x;
            }
        }
        executeInstruction(next_instruction, &x);
    }

    return total;
}

/// Convert the string to an enum
///
fn parseInstruction(line: []const u8) !InstructionData {
    const in = line[0];
    return switch (in) {
        'n' => InstructionData{ .type = InstructionType.noop, .value = 0, .cycles = 1 },
        'a' => InstructionData{ .type = InstructionType.addx, .value = try std.fmt.parseInt(isize, line[5..], 10), .cycles = 2 },
        else => @panic("Invalid instruction"),
    };
}

/// Modify the register based on the instruction
///
fn executeInstruction(data: InstructionData, x: *isize) void {
    switch (data.type) {
        InstructionType.noop => {},
        InstructionType.addx => x.* += data.value,
    }
}
