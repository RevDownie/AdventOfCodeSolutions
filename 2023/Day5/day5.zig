const std = @import("std");

const input_file = @embedFile("input.txt");

const Seed = struct {
    start: u64,
    end: u64,
};

const Seeds = struct {
    ranges: [20]Seed,
    count: usize,
};

const Map = struct {
    dst_start: u64,
    src_start: u64,
    range: u64,
};

const Maps = [8]std.ArrayList(Map);

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

    const seeds_1 = try part1ParseSeeds(input_file[0..]);
    const seeds_2 = try part2ParseSeeds(input_file[0..]);
    var maps = try parseMaps(input_file[0..], fba.allocator());

    const result_1 = run(seeds_1, maps);
    const result_2 = run(seeds_2, maps);

    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, duration / 1000000.0 });
}

/// Seeds are just indices
///
fn part1ParseSeeds(data: []const u8) !Seeds {
    var seeds = Seeds{ .ranges = undefined, .count = 0 };

    var line_it = std.mem.tokenize(u8, data, "\n");

    if (line_it.next()) |line| {
        var seed_it = std.mem.tokenize(u8, line, " ");
        _ = seed_it.next(); //Skip "seeds:"
        while (seed_it.next()) |seed| {
            const seed_id = try std.fmt.parseInt(u64, seed, 10);
            seeds.ranges[seeds.count] = Seed{ .start = seed_id, .end = seed_id + 1 };
            seeds.count += 1;
        }
    }

    return seeds;
}

/// Seeds are pairs of index and range
///
fn part2ParseSeeds(data: []const u8) !Seeds {
    var seeds = Seeds{ .ranges = undefined, .count = 0 };

    var line_it = std.mem.tokenize(u8, data, "\n");

    if (line_it.next()) |line| {
        var seed_it = std.mem.tokenize(u8, line, " ");
        _ = seed_it.next(); //Skip "seeds:"
        while (seed_it.next()) |seed| {
            const seed_start = try std.fmt.parseInt(u64, seed, 10);
            const seed_range = try std.fmt.parseInt(u64, seed_it.next() orelse "", 10);
            seeds.ranges[seeds.count] = Seed{ .start = seed_start, .end = seed_start + seed_range };
            seeds.count += 1;
        }
    }

    return seeds;
}

fn parseMaps(data: []const u8, allocator: std.mem.Allocator) !Maps {
    var maps = [_]std.ArrayList(Map){std.ArrayList(Map).init(allocator)} ** 8;
    var count: u32 = 0;

    var line_it = std.mem.tokenize(u8, data, "\n");
    _ = line_it.next(); //Skip "seeds:"

    while (line_it.next()) |line| {
        if (isDigit(line[0]) == false) {
            count += 1;
            continue; //Skip the title but move to the next map
        }

        var map_it = std.mem.tokenize(u8, line, " ");
        try maps[count].append(Map{ .dst_start = try std.fmt.parseInt(u64, map_it.next() orelse "", 10), .src_start = try std.fmt.parseInt(u64, map_it.next() orelse "", 10), .range = try std.fmt.parseInt(u64, map_it.next() orelse "", 10) });
    }
    return maps;
}

/// There is a mapping function to convert seeds to soil, soil to fertilizer until we get to location
/// find the closest location for the given seeds
///
/// The maps are sequential so it goes seeds-soil, soil-fertlizer, etc in the data
///
fn run(seeds: Seeds, maps: Maps) u64 {
    var i: usize = 0;
    var min_loc: u64 = std.math.maxInt(u64);
    while (i < seeds.count) : (i += 1) {
        var seed = seeds.ranges[i].start;
        while (seed < seeds.ranges[i].end) : (seed += 1) {
            var input = seed;
            for (maps) |map| {
                input = performMap(input, map.items);
            }

            if (input < min_loc) {
                min_loc = input;
            }
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
