const std = @import("std");
const io = std.io;
const fs = std.fs;

const max_bowls = 100;
const grid_width: u32 = 100;
const grid_area = grid_width * grid_width;
const grid_width_with_border = grid_width + 2;
const grid_area_with_border = grid_width_with_border * grid_width_with_border;
const nodes_buffer_size = grid_area_with_border * 4;

/// Advent of code - Day 9
///
/// Part 1 - Find all heights in the heightmap that are surrounded by higher points on the cardinal axes (i.e. bowls)
/// Part 2 - Find all the orthogonals that lead to the bowls
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

    const heightmap = build_heightmap(input_buffer[0..input_len]);
    const bowl_indices = try find_bowl_indices(heightmap[0..]);
    defer bowl_indices.deinit();

    const largest_basin_sizes = try calculate_largest_basin_sizes(heightmap[0..], bowl_indices.items);

    const result_1 = calculate_bowls_total_risk(heightmap[0..], bowl_indices.items);
    const result_2 = combine_basin_sizes(largest_basin_sizes[0..]);
    try stdout.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Convert the raw data to a grid and put a border round it to remove the need for bounds checks
///
fn build_heightmap(input_buffer: []u8) [grid_area_with_border]u8 {
    var hm = [_]u8{255} ** grid_area_with_border;
    var hm_idx = grid_width_with_border + 1;
    var inner_count: u32 = 0;
    for (input_buffer) |c| {
        if (c != '\n') {
            hm[hm_idx] = c - '0';
            hm_idx += 1;
            inner_count += 1;

            if (inner_count == grid_width) {
                hm_idx += 2;
                inner_count = 0;
            }
        }
    }

    return hm;
}

fn find_bowl_indices(heightmap: []const u8) !std.ArrayList(u32) {
    const allocator = std.heap.page_allocator;
    var bowl_indices = std.ArrayList(u32).init(allocator);
    try bowl_indices.ensureTotalCapacity(max_bowls);

    var i = grid_width_with_border + 1;
    const end = heightmap.len - grid_width_with_border - 1;
    while (i < end) : (i += 1) {
        const l = i - 1;
        const r = i + 1;
        const u = i - grid_width_with_border;
        const d = i + grid_width_with_border;
        const h = heightmap[i];

        if (heightmap[l] > h and heightmap[r] > h and heightmap[u] > h and heightmap[d] > h) {
            try bowl_indices.append(i);
        }
    }

    return bowl_indices;
}

fn calculate_bowls_total_risk(heightmap: []const u8, indices: []u32) u32 {
    var total_risk: u32 = 0;
    for (indices) |i| {
        total_risk += 1 + heightmap[i];
    }

    return total_risk;
}

/// Breadth-first search from each "bowl" counting the orthogonal cells that are higher than the previous
/// terminating at >=9 or lower than previous
///
/// TODO: Multithread
///
fn calculate_largest_basin_sizes(heightmap: []const u8, bowl_indices: []u32) ![3]u32 {
    const IndexQueue = std.TailQueue(u32);

    //Hold all bowl sizes and we'll find the top 3 at the end so we can parallelise
    const allocator = std.heap.page_allocator;
    var sizes = try allocator.alloc(u32, bowl_indices.len);
    defer allocator.free(sizes);

    var nodes_buffer: [nodes_buffer_size]IndexQueue.Node = undefined;
    var node_buffer_head: usize = 0;

    //Explore out from each low point - doing a BFS
    for (bowl_indices) |bowl_idx, size_idx| {
        var to_explore = IndexQueue{};
        nodes_buffer[node_buffer_head] = IndexQueue.Node{ .data = bowl_idx };
        to_explore.append(&nodes_buffer[node_buffer_head]);
        node_buffer_head += 1;

        var explored = std.StaticBitSet(grid_area_with_border).initEmpty();

        while (to_explore.len > 0) {
            const i = to_explore.popFirst().?.data;
            const h = heightmap[i];
            const cardinal_idxs = [_]u32{ i - 1, i + 1, i - grid_width_with_border, i + grid_width_with_border };
            for (cardinal_idxs) |ci| {
                if (heightmap[ci] < 9 and heightmap[ci] > h and explored.isSet(ci) == false) {
                    nodes_buffer[node_buffer_head] = IndexQueue.Node{ .data = ci };
                    to_explore.append(&nodes_buffer[node_buffer_head]);
                    node_buffer_head += 1;
                }
            }
            explored.set(i);
        }

        sizes[size_idx] = @truncate(u32, explored.count());
    }

    //Not very efficient doing a full sort - better doing a selection or something but fine for now
    var largest_sizes = [_]u32{ 0, 0, 0 };
    std.sort.sort(u32, sizes, {}, comptime std.sort.desc(u32));
    var i: u32 = 0;
    while (i < largest_sizes.len) : (i += 1) {
        largest_sizes[i] = sizes[i];
    }

    return largest_sizes;
}

fn combine_basin_sizes(sizes: []const u32) u32 {
    var total: u32 = 1;

    for (sizes) |s| {
        total *= s;
    }

    return total;
}
