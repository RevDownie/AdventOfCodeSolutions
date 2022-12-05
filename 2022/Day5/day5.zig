const std = @import("std");
const Allocator = std.mem.Allocator;
const CrateStack = std.SinglyLinkedList(u8); //Stacks are thread safe and we don't need that so just using a list

const input_file = @embedFile("input.txt");
const NUM_STACKS = 9;
const INIT_MAX_STACK_HEIGHT = 8;

/// Advent of code - Day 5
///
/// Part 1 - Stacks. Build the starting state of 9 stacks from the input and modify the state based on instructions
/// Part 2 - ???
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    var buffer: [@sizeOf(CrateStack.Node) * NUM_STACKS * INIT_MAX_STACK_HEIGHT]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);

    var stacks = try buildInitState(input_file[0..], fba.allocator());

    const instruction_offset = (4 * NUM_STACKS) * (INIT_MAX_STACK_HEIGHT + 1) + 1;
    try executeInstructions(input_file[instruction_offset..], stacks[0..]);

    const result_1 = readTopCrates(stacks);
    const result_2 = 0;
    std.debug.print("Part 1: {s}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Input is in the format [A] [B] [C] with each col a stack and each row crates
///
fn buildInitState(data: []const u8, allocator: Allocator) ![NUM_STACKS]CrateStack {
    var stacks: [NUM_STACKS]CrateStack = undefined;
    for (stacks) |_, c| {
        stacks[c] = CrateStack{};
        var r: isize = INIT_MAX_STACK_HEIGHT - 1;
        while (r >= 0) : (r -= 1) {
            const crate = data[c * 4 + @intCast(u32, r) * (4 * NUM_STACKS) + 1];
            if (crate != ' ') {
                var node = try allocator.create(CrateStack.Node);
                node.* = CrateStack.Node{ .data = crate };
                stacks[c].prepend(node);
            }
        }
    }

    return stacks;
}

/// Decode the instructions in the form 'move NN from F to T' and then apply those changes to the state
///
fn executeInstructions(data: []const u8, stacks: []CrateStack) !void {
    var i: usize = 0;
    while (i < data.len) {
        i += 5;
        var j: usize = i + 1;
        while (data[j] != ' ') : (j += 1) {}
        const n = try std.fmt.parseUnsigned(u32, data[i..j], 10);

        i = j + 6;
        const from = data[i] - 1 - '0';

        i += 5;
        const to = data[i] - 1 - '0';

        i += 2; // Skip to the start of the next instruction

        var count: usize = 0;
        while (count < n) : (count += 1) {
            var node = stacks[from].popFirst();
            stacks[to].prepend(node.?);
        }
    }
}

/// Read the top value of each stack into the string buffer
///
fn readTopCrates(stacks: [NUM_STACKS]CrateStack) [NUM_STACKS]u8 {
    var str: [NUM_STACKS]u8 = undefined;
    for (stacks) |s, i| {
        str[i] = s.first.?.data;
    }
    return str;
}

/// WATCH OUT THIS CONSUMES THE STACK
///
fn prettyPrint(stacks: []CrateStack) void {
    for (stacks) |*s, i| {
        std.debug.print("{}: ", .{(i + 1)});

        var n = s.*.popFirst();
        while (n != null) {
            std.debug.print("{},", .{n.?.data});
            n = s.*.popFirst();
        }
        std.debug.print("\n", .{});
    }
}
