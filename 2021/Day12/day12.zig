const std = @import("std");
const io = std.io;
const fs = std.fs;

const input_file = @embedFile("input.txt");

const stack_size = 1000;

const START: u8 = 0;
const END: u8 = 1;

const matrix_width: u8 = 12;
const num_nodes = matrix_width * matrix_width;
const AdjacencyMatrix = std.StaticBitSet(num_nodes);
const SmallCaveSet = std.AutoHashMap(u8, bool);

const primes = [_]u32{ 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541 };

/// Advent of code - Day 12
///
/// Part 1 - Exhaustive graph search of all paths from start to end - not visiting "small caves" more than once
///
pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const timer = std.time.Timer;
    const t = try timer.start();

    var small_cave_set = SmallCaveSet.init(std.heap.page_allocator);
    defer small_cave_set.deinit();

    const adjacency_matrix = try build_adjacency_matrix(input_file[0..], &small_cave_set);

    const result_1 = count_start_to_end_paths(adjacency_matrix, small_cave_set);
    const result_2 = 0;
    try stdout.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Each edge of the graph is on a line
///
fn build_adjacency_matrix(input_data: []const u8, small_cave_set: *SmallCaveSet) !AdjacencyMatrix {
    var adjacency_matrix = AdjacencyMatrix.initEmpty();
    var id_map = std.StringHashMap(u8).init(std.heap.page_allocator);
    defer id_map.deinit();
    var next_id = END + 1;

    var line_it = std.mem.split(input_data, "\n");
    while (line_it.next()) |line| {
        var node_it = std.mem.split(line, "-");

        const from_name = node_it.next().?;
        const from = try convert_node_to_id(from_name, &id_map, &next_id);
        const to_name = node_it.next().?;
        const to = try convert_node_to_id(to_name, &id_map, &next_id);

        //Bi-directional
        const adj_idx = to * matrix_width + from;
        const adj_idx_rev = from * matrix_width + to;
        adjacency_matrix.set(adj_idx);
        adjacency_matrix.set(adj_idx_rev);

        const to_is_lower = to_name[0] >= 'a';
        if (to_is_lower and small_cave_set.*.contains(to) == false) {
            try small_cave_set.*.putNoClobber(to, true);
        }
        const from_is_lower = from_name[0] >= 'a';
        if (from_is_lower and small_cave_set.*.contains(from) == false) {
            try small_cave_set.*.putNoClobber(from, true);
        }
    }

    return adjacency_matrix;
}

/// DFS (as we are exhaustive) to explore all paths from START to END that don't go through "small caves" more than once
/// A neat trick I saw online to track the visited nodes is to assign each a prime number so the modulo will tell you if it is visited
///
fn count_start_to_end_paths(adjacency_matrix: AdjacencyMatrix, small_cave_set: SmallCaveSet) u32 {
    var node_stack: [stack_size]u8 = undefined;
    var visited_primes_stack: [stack_size]u32 = undefined;
    var stack_head: u32 = 0;

    node_stack[0] = START;
    visited_primes_stack[0] = 1;
    stack_head += 1;

    var num_paths: u32 = 0;

    //Start the depth first search until we have no more paths to explore
    //Paths terminate at END
    while (stack_head > 0) {
        stack_head -= 1;
        const id = node_stack[stack_head];

        if (id == END) {
            num_paths += 1;
            continue;
        }

        //Check we haven't marked this node as visited and therefore should ignore
        var visited_primes = visited_primes_stack[stack_head];
        const id_prime = primes[id];
        const has_visited = visited_primes % id_prime == 0;
        if (has_visited) {
            continue;
        }

        //Can't visit small caves more than once
        const is_small_cave = small_cave_set.contains(id);
        if (is_small_cave) {
            //Mark as visited
            visited_primes *= id_prime;
        }

        //Push all the adjacent nodes for exploration
        var to_edge: u8 = 0;
        while (to_edge < matrix_width) : (to_edge += 1) {
            const adj_idx = id * matrix_width + to_edge;
            if (adjacency_matrix.isSet(adj_idx)) {
                node_stack[stack_head] = to_edge;
                visited_primes_stack[stack_head] = visited_primes;
                stack_head += 1;
            }
        }
    }

    return num_paths;
}

fn convert_node_to_id(node_name: []const u8, id_map: *std.StringHashMap(u8), next_id: *u8) !u8 {
    if (std.mem.eql(u8, node_name, "start")) {
        return START;
    }
    if (std.mem.eql(u8, node_name, "end")) {
        return END;
    }

    const id_opt = id_map.*.get(node_name);
    if (id_opt) |id| {
        return id;
    }

    const new_id = next_id.*;
    try id_map.*.putNoClobber(node_name, new_id);
    next_id.* += 1;

    return new_id;
}
