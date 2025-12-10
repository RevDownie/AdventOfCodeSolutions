const std = @import("std");

const input_file = @embedFile("input_day8.txt");
const max_connections = 1000;

const Vec3 = @Vector(3, i64);

const Route = struct { a: usize, b: usize, dist_sqrd: u64 };

/// Advent of code - Day 8
///
/// Part 1 - Connect 1000 closest junction boxes and calculate the circuit length of the largest 3 circuits
/// Part 2 - Connect closest junction boxes until only one circuit and calculate the product of the last 2 x-coords connectect
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const result = try run(input_file[0..], gpa.allocator());
    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result.p1, result.p2, duration / 1000000.0 });
}

/// Find distances, sort and then go through merging edges
///
fn run(data: []const u8, allocator: std.mem.Allocator) !struct { p1: u64, p2: u64 } {
    var coords = try std.ArrayList(Vec3).initCapacity(allocator, 1000);
    defer coords.deinit(allocator);

    //Parse the coords
    var line_it = std.mem.tokenizeScalar(u8, data, '\n');
    while (line_it.next()) |line| {
        var csv_it = std.mem.tokenizeScalar(u8, line, ',');
        const x = try std.fmt.parseInt(i64, csv_it.next().?, 10);
        const y = try std.fmt.parseInt(i64, csv_it.next().?, 10);
        const z = try std.fmt.parseInt(i64, csv_it.next().?, 10);
        try coords.append(allocator, Vec3{ x, y, z });
    }

    const coords_slice = coords.items;
    const n = coords_slice.len;

    //All pair distances: O(n^2), only i < j
    const approx_pairs = n * (n - 1) / 2;
    var pair_distances = try std.ArrayList(Route).initCapacity(allocator, approx_pairs);
    defer pair_distances.deinit(allocator);

    var i: usize = 0;
    while (i < n - 1) : (i += 1) {
        var j = i + 1;
        while (j < n) : (j += 1) {
            try pair_distances.append(
                allocator,
                .{ .a = i, .b = j, .dist_sqrd = distSqrd(coords_slice[i], coords_slice[j]) },
            );
        }
    }

    std.mem.sort(Route, pair_distances.items, {}, struct {
        fn asc(_: void, a: Route, b: Route) bool {
            return a.dist_sqrd < b.dist_sqrd;
        }
    }.asc);

    const result = try mergingCircuits(coords_slice, pair_distances.items, allocator);
    return .{ .p1 = result.p1, .p2 = result.p2 };
}

inline fn distSqrd(a: Vec3, b: Vec3) u64 {
    const delta = b - a;
    const delta_sq = delta * delta;
    return @intCast(delta_sq[0] + delta_sq[1] + delta_sq[2]);
}

/// Simulate connecting pairs in order of distance.
/// Part 1: product of largest 3 circuits after `max_connections` pairs processed.
/// Part 2: product of X coords of the last pair that merges everything into one circuit.
///
fn mergingCircuits(coords: []const Vec3, pairs_sorted: []const Route, allocator: std.mem.Allocator) !struct { p1: u64, p2: u64 } {
    const n = coords.len;

    var comp = try allocator.alloc(usize, n);
    defer allocator.free(comp);

    //Initially each node is its own circuit.
    var i: usize = 0;
    while (i < n) : (i += 1) {
        comp[i] = i;
    }

    var p1: u64 = 0;
    var p2: u64 = 0;
    var num_circuits: usize = n;
    var connections_seen: usize = 0;

    var edge_index: usize = 0;
    while (num_circuits > 1 and edge_index < pairs_sorted.len) : (edge_index += 1) {
        const p = pairs_sorted[edge_index];

        //Part 1: snapshot after exactly `max_connections` pairs seen
        if (connections_seen == max_connections) {
            p1 = try productOfLargest(comp, allocator);
        }
        connections_seen += 1;

        const ca = comp[p.a];
        const cb = comp[p.b];
        if (ca == cb) {
            //Already in same circuit: nothing changes
            continue;
        }

        //Merge circuit `cb` into `ca` by relabeling
        var j: usize = 0;
        while (j < n) : (j += 1) {
            if (comp[j] == cb) {
                comp[j] = ca;
            }
        }
        num_circuits -= 1;

        //Part 2: this is the last merge that produces a single circuit
        if (num_circuits == 1) {
            const ax = coords[p.a][0];
            const bx = coords[p.b][0];
            p2 = @intCast(ax * bx);
            break;
        }
    }

    return .{ .p1 = p1, .p2 = p2 };
}

/// Compute product of the 3 largest circuit sizes from the `comp` labelling.
///
fn productOfLargest(comp: []const usize, allocator: std.mem.Allocator) !u64 {
    const n = comp.len;
    var counts = try allocator.alloc(usize, n);
    defer allocator.free(counts);
    @memset(counts, 0);

    var i: usize = 0;
    while (i < n) : (i += 1) {
        counts[comp[i]] += 1;
    }

    //Collect non-zero sizes
    var sizes = try std.ArrayList(usize).initCapacity(allocator, n);
    defer sizes.deinit(allocator);

    i = 0;
    while (i < n) : (i += 1) {
        if (counts[i] != 0) {
            try sizes.append(allocator, counts[i]);
        }
    }

    //Sort so we can grab the largest 3
    std.mem.sort(usize, sizes.items, {}, struct {
        fn desc(_: void, a: usize, b: usize) bool {
            return a > b;
        }
    }.desc);

    //Product of largest 3
    std.debug.assert(sizes.items.len >= 3);
    return @as(u64, sizes.items[0]) * @as(u64, sizes.items[1]) * @as(u64, sizes.items[2]);
}
