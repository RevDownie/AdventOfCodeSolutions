const std = @import("std");

const input_file = @embedFile("input.txt");

const Result = struct {
    part1: u32,
    part2: u32,
};

/// Advent of code - Day 4
///
/// Part 1 - Count number of matches in both lists and double score for each match
/// Part 2 - Madness! Count the number of originals and copies of cards
///
pub fn main() !void {
    const timer = std.time.Timer;

    var buffer: [1024 * 30]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);

    var t = try timer.start();

    const result = try run(input_file[0..], fba.allocator());
    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result.part1, result.part2, duration / 1000000.0 });
}

/// Part1: Read the numbers from one list and compare the numbers from the other list
/// the first match is worth 1 point then doubled for each match. Sum the total score
///
/// Part2: So each winning number wins a copy of the cards below. So if we have 4 matches in card 1 we win a copy of card 2,3,4,5
/// when you win on card 2 all copies of card 2 win. We have to count the total number of cards at the end
///
fn run(data: []const u8, allocator: std.mem.Allocator) !Result {
    var card_counts = [_]u32{0} ** 200;
    var score: u32 = 0;

    var line_it = std.mem.tokenize(u8, data, "\n");
    while (line_it.next()) |line| {
        var winning_set = std.AutoHashMap(u32, void).init(allocator);

        var card_it = std.mem.tokenize(u8, line, " ");
        _ = card_it.next(); //Skip the card label
        const unparsed_card_num = card_it.next() orelse @panic("No card num");
        const card_idx = try std.fmt.parseInt(u32, unparsed_card_num[0 .. unparsed_card_num.len - 1], 10) - 1;
        card_counts[card_idx] += 1; // Add the original card

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

        winning_set.deinit();

        //Count score - use the geometric sequence equation 1,2,4,8,16
        if (num_matches > 0) {
            score += std.math.pow(u32, 2, (num_matches - 1));
        }

        //Make copies for part 2
        var i: usize = 0;
        while (i < num_matches) : (i += 1) {
            card_counts[card_idx + i + 1] += 1 * card_counts[card_idx];
        }
    }

    var total_cards: u32 = 0;
    for (card_counts) |x| {
        total_cards += x;
    }

    return Result{ .part1 = score, .part2 = total_cards };
}
