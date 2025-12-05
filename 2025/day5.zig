const std = @import("std");

const input_file = @embedFile("input_day5.txt");

const Range = struct { min: u64, max: u64 };

/// Advent of code - Day 5
///
/// Part 1 - Find the fresh / spolied ingredients by checking if they fall within a range
/// Part 2 - Merge ranges. Find the total number of ingredients in the given ranges merging the overlaps
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

/// Merge ranges by sorting them by min and then sweeping them to create a new range list with no overlaps
///
fn run(data: []const u8, allocator: std.mem.Allocator) !struct { p1: u64, p2: u64 } {
    var ranges = try std.ArrayList(Range).initCapacity(allocator, 200);
    defer ranges.deinit(allocator);

    //Parse the ranges
    var line_it = std.mem.splitSequence(u8, data, "\n");
    while (line_it.next()) |line| {
        if (line.len == 0) {
            //Hit the empty line in the middle. Now onto the next block that contains the list of ingredients
            break;
        }
        var range_it = std.mem.tokenizeScalar(u8, line, '-');
        const min = try std.fmt.parseInt(u64, range_it.next().?, 10);
        const max = try std.fmt.parseInt(u64, range_it.next().?, 10);
        try ranges.append(allocator, .{ .min = min, .max = max });
    }

    //Remove overlaps by merging the ranges - sorting first and then merging in place
    std.mem.sort(Range, ranges.items, {}, rangeSortPredicate);

    var write_len: usize = 0;
    var current = ranges.items[0];
    var i: usize = 1;
    while (i < ranges.items.len) : (i += 1) {
        const r = ranges.items[i];
        if (r.min <= current.max) {
            if (r.max > current.max) {
                current.max = r.max;
            }
        } else {
            ranges.items[write_len] = current;
            write_len += 1;
            current = r;
        }
    }
    //Push the last accumulated range
    ranges.items[write_len] = current;
    write_len += 1;
    const merged_ranges = ranges.items[0..write_len];

    //Part 1 - Check if the given ingredients are fresh
    var total_1: u64 = 0;
    while (line_it.next()) |line| {
        if (line.len == 0) {
            break;
        }

        const val = try std.fmt.parseInt(u64, line, 10);
        for (merged_ranges) |r| {
            if (val < r.min) {
                break; // no later range can contain it
            }
            if (val >= r.min and val <= r.max) {
                total_1 += 1;
                break;
            }
        }
    }

    //Part 2 - Total range of fresh ingredients
    var total_2: u64 = 0;
    for (merged_ranges) |r| {
        total_2 += (r.max - r.min) + 1;
    }

    return .{ .p1 = total_1, .p2 = total_2 };
}

fn rangeSortPredicate(_: void, a: Range, b: Range) bool {
    if (a.min == b.min) return a.max < b.max;
    return a.min < b.min;
}
