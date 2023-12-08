const std = @import("std");

const input_file = @embedFile("input.txt");

const Node = struct {
    child_inds: [2]u32,
};

const Result = struct {
    part_1: u64,
    part_2: u64,
};

/// Advent of code - Day 8
///
/// Part 1 - Parse a list of LR instructions and follow the path from AAA to ZZZ
/// Part 2 - As part 1 but for each node ending in A explore until you find a node ending in Z
///
pub fn main() !void {
    const timer = std.time.Timer;

    var t = try timer.start();

    var buffer: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);

    const result = try run(input_file[0..], fba.allocator());
    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result.part_1, result.part_2, duration / 1000000.0 });
}

/// Part 1: Given a list of looping left or right instructions pick the left or right option from the graph starting at
/// AAA and repeating until reaching ZZZ. Count the number of steps
///
/// Part 2: Start at all nodes ending in 'A' and repeating until all nodes end in Z on the same instruction. Count the number of steps.
/// Brute forcing this will take too long so we simulate each individuallyy until they end and then find the lowest common multiple which tells
/// us when they would have all ended together. This is possible because of the repeating pattern of instructions that are followed
///
fn run(data: []const u8, allocator: std.mem.Allocator) !Result {
    var line_it = std.mem.tokenize(u8, data, "\n");

    const instructions = line_it.next() orelse @panic("Missing instructions");

    var part1_start_nodes = try std.ArrayList(u32).initCapacity(allocator, 1);
    defer part1_start_nodes.deinit();
    try part1_start_nodes.append(encodeNodeIndex("AAA"));

    var part2_start_nodes = try std.ArrayList(u32).initCapacity(allocator, 10);
    defer part2_start_nodes.deinit();

    // Build the graph - just using adjacency indices
    var graph: [174763]Node = undefined;
    while (line_it.next()) |line| {
        const node_idx = encodeNodeIndex(line[0..3]);
        graph[node_idx] = Node{ .child_inds = [_]u32{ encodeNodeIndex(line[7..10]), encodeNodeIndex(line[12..15]) } };

        if (line[2] == 'A') {
            //Track as a starting node for part 2
            try part2_start_nodes.append(node_idx);
        }
    }

    var part1_steps = try std.ArrayList(u64).initCapacity(allocator, part1_start_nodes.items.len);
    defer part1_steps.deinit();

    var part2_steps = try std.ArrayList(u64).initCapacity(allocator, part2_start_nodes.items.len);
    defer part2_steps.deinit();

    try searchGraph(&part1_start_nodes, &part1_steps, &graph, instructions, endOnZZZ);
    try searchGraph(&part2_start_nodes, &part2_steps, &graph, instructions, endOn__Z);

    //For part 2 we need to find the lowest common multiple - just applying a reduce
    var l = lcm(part2_steps.items[0], part2_steps.items[1]);
    for (part2_steps.items[2..]) |s| {
        l = lcm(l, s);
    }

    return Result{ .part_1 = part1_steps.items[0], .part_2 = l };
}

/// Start at the given node and search the graph until the end condition is met, processing the list of left and right instructions
/// Returns the number of steps until the end condition for each start node
///
fn searchGraph(start_node_inds: *std.ArrayList(u32), steps_per_node: *std.ArrayList(u64), graph: []const Node, instructions: []const u8, comptime endCondition: fn (idx: u32) bool) !void {
    var next_node_inds = start_node_inds.*.items;

    var instruction_idx: u32 = 0;
    while (true) : (instruction_idx += 1) {
        const dir = instructions[instruction_idx % instructions.len];
        const child_idx: u8 = switch (dir) {
            'L' => 0,
            'R' => 1,
            else => @panic("Incorrect instruction"),
        };

        var num_end: u32 = 0;
        for (next_node_inds) |*node_idx| {
            if (endCondition(node_idx.*)) {
                //Previously reached end
                num_end += 1;
                continue;
            }

            const next_node_idx = graph[node_idx.*].child_inds[child_idx];
            if (endCondition(next_node_idx)) {
                try steps_per_node.append(instruction_idx + 1);
            }

            node_idx.* = next_node_idx;
        }

        if (num_end == next_node_inds.len) {
            return;
        }
    }

    unreachable;
}

/// Returns true if all letters are ZZZ
///
fn endOnZZZ(encoded: u32) bool {
    return encoded == encodeNodeIndex("ZZZ");
}

/// Returns true if last letter is Z
///
fn endOn__Z(encoded: u32) bool {
    return (encoded & 0b111111) == ('Z' - '0');
}

/// Pack the 3 chars AAA-ZZZ into a 32bit unique num
///
inline fn encodeNodeIndex(chars: []const u8) u32 {
    const x: u32 = @intCast(chars[0] - '0');
    const y: u32 = @intCast(chars[1] - '0');
    const z: u32 = @intCast(chars[2] - '0');

    return x << 12 | y << 6 | z;
}

/// Find the lowest common multiple of 2 numbers
///
fn lcm(a: u64, b: u64) u64 {
    const greatest = @max(a, b);
    const smallest = @min(a, b);

    var i = greatest;
    while (true) : (i += greatest) {
        if (i % smallest == 0) {
            return i;
        }
    }

    unreachable;
}
