const std = @import("std");

const input_file = @embedFile("input.txt");

const Seed = struct {
    start: u64,
    range: u64,
    type: u8,
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

const Maps = [7]std.ArrayList(Map);

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
            seeds.ranges[seeds.count] = Seed{ .start = seed_id, .range = 1, .type = 0 };
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
            seeds.ranges[seeds.count] = Seed{ .start = seed_start, .range = seed_range, .type = 0 };
            seeds.count += 1;
        }
    }

    return seeds;
}

fn parseMaps(data: []const u8, allocator: std.mem.Allocator) !Maps {
    var maps = [_]std.ArrayList(Map){std.ArrayList(Map).init(allocator)} ** 7;
    var count: u32 = 0;

    var line_it = std.mem.tokenize(u8, data, "\n");
    _ = line_it.next(); //Skip "seeds:"
    _ = line_it.next();

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
/// This uses a recursive range splitting approach
///
fn run(seeds: Seeds, maps: Maps) u64 {
    var seed_stack: [100]Seed = undefined;
    var head: usize = seeds.count;

    //Fill the starting input for seed to soil
    var i: usize = 0;
    while (i < seeds.count) : (i += 1) {
        seed_stack[i] = seeds.ranges[i];
    }

    var min_loc: u64 = std.math.maxInt(u64);

    outer: while (head > 0) {
        head -= 1;
        const seed = seed_stack[head];

        //Check if the seed has made it through all the maps to the final location and update the min
        if (seed.type == maps.len) {
            if (seed.start < min_loc) {
                min_loc = seed.start;
            }
            continue :outer;
        }

        //Map to the next layer
        const map = maps[seed.type];
        for (map.items) |map_range| {
            const seed_end = seed.start + seed.range - 1;
            const map_end = map_range.src_start + map_range.range - 1;

            //Check if range is full contained and if so we can remap and proceed to the next layer
            if (seed.start >= map_range.src_start and seed_end <= map_end) {
                seed_stack[head] = Seed{ .start = seed.start + map_range.dst_start - map_range.src_start, .range = seed.range, .type = seed.type + 1 };
                head += 1;
                continue :outer;
            }

            //Check if right is overhanging and split in 2
            if (seed.start >= map_range.src_start and seed.start < map_end) {
                //Left
                const overflow = seed_end - map_end;
                seed_stack[head] = Seed{ .start = seed.start, .range = seed.range - overflow, .type = seed.type };
                head += 1;

                //Right
                seed_stack[head] = Seed{ .start = map_end, .range = overflow, .type = seed.type };
                head += 1;
                continue :outer;
            }

            //Check if left is overhanging and split in 2
            if (seed_end >= map_range.src_start and seed_end <= map_end) {
                //Left
                const overflow = map_range.src_start - seed.start;
                seed_stack[head] = Seed{ .start = seed.start, .range = overflow, .type = seed.type };
                head += 1;

                //Right
                seed_stack[head] = Seed{ .start = map_range.src_start, .range = seed.range - overflow, .type = seed.type };
                head += 1;
                continue :outer;
            }

            //Check if the range extends beyond bounds on both sides and split into 3
            if (seed.start < map_range.src_start and seed_end > map_end) {
                //Left
                const overflow_l = map_range.src_start - seed.start;
                seed_stack[head] = Seed{ .start = seed.start, .range = overflow_l, .type = seed.type };
                head += 1;

                //Center
                seed_stack[head] = Seed{ .start = map_range.src_start, .range = map_range.range, .type = seed.type };
                head += 1;

                //Right
                const overflow_r = seed_end - map_end;
                seed_stack[head] = Seed{ .start = map_end, .range = overflow_r, .type = seed.type };
                head += 1;
                continue :outer;
            }
        }

        //No explicit mapping - just keeps the same values and moves to the next layer
        seed_stack[head] = Seed{ .start = seed.start, .range = seed.range, .type = seed.type + 1 };
        head += 1;
    }

    return min_loc;
}

inline fn isDigit(char: u8) bool {
    return char >= '0' and char <= '9';
}
