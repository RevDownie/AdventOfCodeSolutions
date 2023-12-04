const std = @import("std");

const input_file = @embedFile("input.txt");

/// Advent of code - Day 4
///
/// Part 1 - Count number of matches in both lists and double score for each match
/// Part 2 - ???
///
pub fn main() !void {
    const timer = std.time.Timer;

    var buffer: [1024 * 20]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);

    var t = try timer.start();

    const result_1 = try part1(input_file[0..], fba.allocator());
    const result_2 = 0;
    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, duration / 1000000.0 });
}

/// Read the numbers from one list and compare the numbers from the other list
/// the first match is worth 1 point then doubled for each match. Sum the total score
///
fn part1(data: []const u8, allocator: std.mem.Allocator) !u32 {
    var total: u32 = 0;

    var line_it = std.mem.tokenize(u8, data, "\n");
    while (line_it.next()) |line| {
        var winning_set = std.AutoHashMap(u32, void).init(allocator);

        var card_it = std.mem.tokenize(u8, line, " ");
        _ = card_it.next(); //Skip the card label
        _ = card_it.next();

        //Winning numbers
        while (card_it.next()) |unparsed| {
            if (unparsed[0] == '|') {
                break;
            }
            const num = try std.fmt.parseInt(u32, unparsed, 10);
            try winning_set.put(num, {});
        }

        //Our numbers
        var num_matches: u32 = 0;
        while (card_it.next()) |unparsed| {
            const num = try std.fmt.parseInt(u32, unparsed, 10);
            if (winning_set.get(num)) |_| {
                num_matches += 1;
            }
        }

        //Use the geometric sequence equation 1,2,4,8,16
        if (num_matches > 0) {
            total += std.math.pow(u32, 2, (num_matches - 1));
        }
        winning_set.deinit();
    }

    return total;
}
