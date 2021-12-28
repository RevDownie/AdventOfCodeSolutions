const std = @import("std");
const io = std.io;
const fs = std.fs;

const input_file = @embedFile("input.txt");

const ReadData = struct {
    template: []const u8,
    spawn_map: std.AutoHashMap(u16, u8),
};

const Pair = struct {
    a: u8,
    b: u8,
};

const CountData = struct {
    prev_gen_count: u64,
    curr_gen_count: u64,
};

/// Advent of code - Day 14
///
/// Part 1 - Every pair of characters spawns a new character between them after 10 steps count the lowest and highest characters
/// part 2 - As part 1 but 40 iterations so the polymer would be massive
///
pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const timer = std.time.Timer;
    const t = try timer.start();

    var data = try read_data(input_file[0..]);
    defer data.spawn_map.deinit();

    const result_1 = find_diff_between_most_and_least(data.template, data.spawn_map, 10);
    const result_2 = find_diff_between_most_and_least(data.template, data.spawn_map, 40);
    try stdout.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Read the template which is the starting polymer sequence and the mapping of pairs to new spawn char
///
fn read_data(input_data: []const u8) !ReadData {
    var i: usize = 0;
    while (input_data[i] != '\n') : (i += 1) {}
    const template = input_data[0..i];

    while (input_data[i] != '\n') : (i += 1) {}
    i += 2;

    var spawn_map = std.AutoHashMap(u16, u8).init(std.heap.page_allocator);
    while (i < input_data.len) : (i += 8) {
        const key = make_key(input_data[i], input_data[i + 1]);
        const val = input_data[i + 6];
        try spawn_map.putNoClobber(key, val);
    }

    return ReadData{ .template = template, .spawn_map = spawn_map };
}

/// The memory required to store the polymer will grow really quickly so lets just store the counts of pairs instead
///
fn find_diff_between_most_and_least(template: []const u8, spawn_map: std.AutoHashMap(u16, u8), num_generations: u32) !u64 {
    var pair_counts = std.AutoHashMap(u16, CountData).init(std.heap.page_allocator);
    defer pair_counts.deinit();

    //Populate with all the possible pairs
    var it = spawn_map.keyIterator();
    while (it.next()) |pair| {
        try pair_counts.putNoClobber(pair.*, CountData{ .prev_gen_count = 0, .curr_gen_count = 0 });
    }

    //Start with the template
    var i: usize = 0;
    while (i < template.len - 1) : (i += 1) {
        pair_counts.getPtr(make_key(template[i], template[i + 1])).?.prev_gen_count = 1;
    }

    //Build the polymer
    var gen: u32 = 0;
    while (gen < num_generations) : (gen += 1) {
        try step_generation(&pair_counts, spawn_map);
    }

    //Find the diff between the min and max character count - remember the map is stored as pairs
    var char_count = [_]u64{0} ** 26;
    var count_it = pair_counts.iterator();
    while (count_it.next()) |kv| {
        const pair = kv.key_ptr.*;
        const split = split_key(pair);
        const count = kv.value_ptr.*.prev_gen_count;

        char_count[split.a - 'A'] += count;
        char_count[split.b - 'A'] += count;
    }

    //Shouldn't really sort for finding the min and max
    std.sort.sort(u64, char_count[0..], {}, comptime std.sort.desc(u64));
    var end: usize = 25;
    while (char_count[end] == 0) : (end -= 1) {}
    return (char_count[0] - char_count[end] + 1) / 2;
}

fn step_generation(pair_counts: *std.AutoHashMap(u16, CountData), spawn_map: std.AutoHashMap(u16, u8)) !void {
    var gen_it = pair_counts.iterator();
    while (gen_it.next()) |kv| {
        if (kv.value_ptr.*.prev_gen_count == 0) {
            continue;
        }

        const pair = kv.key_ptr.*;
        const spawned = spawn_map.get(pair).?;
        const split = split_key(pair);

        pair_counts.getPtr(make_key(split.a, spawned)).?.curr_gen_count += kv.value_ptr.*.prev_gen_count;
        pair_counts.getPtr(make_key(spawned, split.b)).?.curr_gen_count += kv.value_ptr.*.prev_gen_count;
    }

    var prep_it = pair_counts.valueIterator();
    while (prep_it.next()) |v| {
        v.prev_gen_count = v.curr_gen_count;
        v.curr_gen_count = 0;
    }
}

inline fn make_key(a: u8, b: u8) u16 {
    return @shlExact(@as(u16, a), 8) | b;
}

inline fn split_key(pair: u16) Pair {
    const a = @truncate(u8, @shrExact(pair & 0xFF00, 8));
    const b = @truncate(u8, pair);
    return Pair{ .a = a, .b = b };
}
