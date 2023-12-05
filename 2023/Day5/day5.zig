const std = @import("std");

const input_file = @embedFile("input.txt");

const Map = struct {
    dst_start: u64,
    src_start: u64,
    range: u64,
};

/// Advent of code - Day 5
///
/// Part 1 - Find the closest location to plant a seed
/// Part 2 - ???
///
pub fn main() !void {
    const timer = std.time.Timer;

    var t = try timer.start();

    var buffer: [1024 * 30]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);

    const result_1 = try part1(input_file[0..], fba.allocator());
    const result_2 = 0;
    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, duration / 1000000.0 });
}

/// There is a mapping function to convert seeds to soil, soil to fertilizer until we get to location
/// find the closest location for the given seeds
///
/// The maps are sequential so it goes seeds-soil, soil-fertlizer, etc in the data
///
fn part1(data: []const u8, allocator: std.mem.Allocator) !u64 {
    var line_it = std.mem.tokenize(u8, data, "\n");

    //Seeds
    var seeds: [20]u64 = undefined;
    var num_seeds: usize = 0;

    if (line_it.next()) |line| {
        var seed_it = std.mem.tokenize(u8, line, " ");
        _ = seed_it.next(); //Skip "seeds:"
        while (seed_it.next()) |seed| {
            seeds[num_seeds] = try std.fmt.parseInt(u64, seed, 10);
            num_seeds += 1;
        }
    }

    //Maps
    var maps = [_]std.ArrayList(Map){std.ArrayList(Map).init(allocator)} ** 8;
    var num_maps: usize = 0;

    while (line_it.next()) |line| {
        if (isDigit(line[0]) == false) {
            num_maps += 1;
            continue; //Skip the title but move to the next map
        }

        var map_it = std.mem.tokenize(u8, line, " ");
        try maps[num_maps].append(Map{ .dst_start = try std.fmt.parseInt(u64, map_it.next() orelse "", 10), .src_start = try std.fmt.parseInt(u64, map_it.next() orelse "", 10), .range = try std.fmt.parseInt(u64, map_it.next() orelse "", 10) });
    }

    //Run
    var i: usize = 0;
    var min_loc: u64 = std.math.maxInt(u64);
    while (i < num_seeds) : (i += 1) {
        var input = seeds[i];
        for (maps) |map| {
            input = performMap(input, map.items);
        }

        if (input < min_loc) {
            min_loc = input;
        }
    }

    return min_loc;
}

inline fn performMap(input: u64, maps: []const Map) u64 {
    for (maps) |map| {
        if (input >= map.src_start and input < map.src_start + map.range) {
            return input + map.dst_start - map.src_start;
        }
    }

    //Rule is we do a 1-1 mapping if no specific mapping found
    return input;
}

inline fn isDigit(char: u8) bool {
    return char >= '0' and char <= '9';
}
