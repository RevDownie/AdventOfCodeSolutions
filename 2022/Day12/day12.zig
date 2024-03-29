const std = @import("std");

const input_file = @embedFile("input.txt");

const ValidMoveFn = fn (u16, u16) bool;

const GRID_WIDTH = 154;
const GRID_HEIGHT = 41;

/// Advent of code - Day 12
///
/// Part 1 - Find the shortest path from S to E that doesn't go up more than one step in elevation
/// Part 2 - Find the shortest path from any 'a' to E
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const result_1 = try findShortestPath(input_file[0..], gpa.allocator(), 'S', 'E', 'z', validMoveForwards);
    const result_2 = try findShortestPath(input_file[0..], gpa.allocator(), 'E', 'S', 'a', validMoveBackwards);

    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Part 1: Each cell in the grid has an altitude denoted a(low) to z(high) we need to find the shortest path from S to E that doesn't take more than one
/// increase in altitude between each step
///
/// Part 2 wants us to find the shortest path from E to any 'a' altitude so we just pathfind in reverse from E until we reach an 'a'
///
/// Djikstra's Algorithm but without any weightings
///
fn findShortestPath(data: []const u8, allocator: std.mem.Allocator, comptime start_symbol: u8, comptime end_symbol: u8, comptime end_altitude: u8, comptime validMoveFn: ValidMoveFn) !u32 {
    var altitudes: [GRID_WIDTH * GRID_HEIGHT]u8 = undefined;
    var distances = [_]u32{std.math.maxInt(u32)} ** (GRID_WIDTH * GRID_HEIGHT);
    var next_node_queue = std.PriorityQueue(u16, []u32, shortestDistComparator).init(allocator, distances[0..]);
    defer next_node_queue.deinit();
    var start_idx: u16 = undefined;
    var end_idx: u16 = undefined;

    //Build the grid
    var i: u16 = 0;
    var grid_idx = i;
    while (i < data.len) : (i += 1) {
        switch (data[i]) {
            start_symbol => {
                start_idx = grid_idx;
            },
            end_symbol => {
                end_idx = grid_idx;
            },
            '\n' => {
                //Skip to the next actual grid element
                continue;
            },
            else => {},
        }

        altitudes[grid_idx] = data[i];
        grid_idx += 1;
    }

    distances[start_idx] = 0;
    altitudes[start_idx] = 'a';
    altitudes[end_idx] = end_altitude;
    try next_node_queue.add(start_idx);
    var visited = std.StaticBitSet(GRID_WIDTH * GRID_HEIGHT).initEmpty();

    //Djikstra's algorithm
    while (next_node_queue.removeOrNull()) |node_idx| {
        //Discard if already seen
        if (visited.isSet(node_idx)) {
            continue;
        }

        //Don't visit again
        visited.set(node_idx);

        //Find adjacent nodes to explore
        const node_idx_sig = @intCast(i16, node_idx);
        const adjacent_indices = [_]i16{ node_idx_sig + 1, node_idx_sig - 1, node_idx_sig - GRID_WIDTH, node_idx_sig + GRID_WIDTH };
        for (adjacent_indices) |u_sig| {
            if (u_sig >= 0 and u_sig < distances.len) {
                const u = @intCast(u16, u_sig);
                if (visited.isSet(u) == false) {
                    if (validMoveFn(altitudes[node_idx], altitudes[u])) {
                        const dist_to_u = distances[node_idx] + 1;
                        if (dist_to_u < distances[u]) {
                            distances[u] = dist_to_u;

                            //Reached destination - don't need to wait for the node to actually be visited
                            if (altitudes[u] == end_altitude) {
                                return distances[u];
                            }
                        }
                        try next_node_queue.add(u);
                    }
                }
            }
        }
    }

    unreachable;
}

/// Return the ordinal with the shortest distance
///
fn shortestDistComparator(distances: []u32, a: u16, b: u16) std.math.Order {
    if (distances[a] < distances[b]) {
        return std.math.Order.lt;
    } else if (distances[b] < distances[a]) {
        return std.math.Order.gt;
    } else {
        return std.math.Order.eq;
    }
}

/// Allow an up step of only one unit. For use when going uphill
///
fn validMoveForwards(v: u16, u: u16) bool {
    return (@intCast(i8, u) - @intCast(i8, v)) <= 1;
}

/// Allow an down step of only one unit. For use when going downhill
///
fn validMoveBackwards(v: u16, u: u16) bool {
    return (@intCast(i8, v) - @intCast(i8, u)) <= 1;
}
