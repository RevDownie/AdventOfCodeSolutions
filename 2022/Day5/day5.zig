const std = @import("std");
const Allocator = std.mem.Allocator;
const CrateStack = std.SinglyLinkedList(u8); //Stacks are thread safe and we don't need that so just using a list

const input_file = @embedFile("input.txt");

const NUM_STACKS = 9;
const INIT_MAX_STACK_HEIGHT = 8;
const INSTRUCTION_OFFSET = (4 * NUM_STACKS) * (INIT_MAX_STACK_HEIGHT + 1) + 1;
const MOVE_BUFFER_SIZE = 50;

/// Advent of code - Day 5
///
/// Part 1 - Stacks. Build the starting state of 9 stacks from the input and modify the state based on instructions
/// Part 2 - Same as part one but moving multiple crates in a single instruction preserves the order rather than reverses it
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    var buffer: [@sizeOf(CrateStack.Node) * NUM_STACKS * INIT_MAX_STACK_HEIGHT]u8 = undefined;

    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    var stacks = try buildInitState(input_file[0..], fba.allocator());
    try executeInstructions9000(input_file[INSTRUCTION_OFFSET..], stacks[0..]);
    const result_1 = readTopCrates(stacks);

    fba = std.heap.FixedBufferAllocator.init(&buffer);
    stacks = try buildInitState(input_file[0..], fba.allocator());
    try executeInstructions9001(input_file[INSTRUCTION_OFFSET..], stacks[0..]);
    const result_2 = readTopCrates(stacks);

    std.debug.print("Part 1: {s}, Part 2: {s} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
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
/// When moving multiple crates it does so one at a time meaning the order is reversed (STACK)
///
fn executeInstructions9000(data: []const u8, stacks: []CrateStack) !void {
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

/// Decode the instructions in the form 'move NN from F to T' and then apply those changes to the state
/// When moving multiple crates it does so in bulk - preserving the order (QUEUE)
///
fn executeInstructions9001(data: []const u8, stacks: []CrateStack) !void {
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

        var queue: [MOVE_BUFFER_SIZE]*CrateStack.Node = undefined;
        var count: usize = 0;
        while (count < n) : (count += 1) {
            queue[n - count - 1] = stacks[from].popFirst().?;
        }
        for (queue[0..n]) |node| {
            stacks[to].prepend(node);
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
