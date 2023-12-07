const std = @import("std");

const input_file = @embedFile("input.txt");

const Hand = struct {
    strength: u32,
    bid: u32,
};

const HandsList = std.ArrayList(Hand);

/// Advent of code - Day 7
///
/// Part 1 - Score poker hands
/// Part 2 - As part one but Jack has become Joker that is the lowest value but can turn to any value needed to make the higest hand
///
pub fn main() !void {
    const timer = std.time.Timer;

    var t = try timer.start();

    var buffer: [1024 * 30]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);

    var hands_1 = try parseHands(input_file[0..], fba.allocator(), calculateHandStrengthPart1);
    defer hands_1.deinit();

    var hands_2 = try parseHands(input_file[0..], fba.allocator(), calculateHandStrengthPart2);
    defer hands_2.deinit();

    const result_1 = try calculateHandScore(&hands_1);
    const result_2 = try calculateHandScore(&hands_2);

    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, duration / 1000000.0 });
}

/// Parse and score the hand strength including Five of a kind, etc
/// 32T3K 765
/// T55J5 684
/// KK677 28
/// KTJJT 220
/// QQQJA 483
///
fn parseHands(data: []const u8, allocator: std.mem.Allocator, comptime strengthFunc: fn (cards: []const u8) u32) !HandsList {
    var hands = HandsList.init(allocator);
    var line_it = std.mem.tokenize(u8, data, "\n");
    while (line_it.next()) |line| {
        var hand_it = std.mem.tokenize(u8, line, " ");
        const cards = hand_it.next() orelse @panic("Missing cards");
        const strength = strengthFunc(cards);
        const bid = try std.fmt.parseInt(u32, hand_it.next() orelse @panic("Missing bid"), 10);
        try hands.append(Hand{ .strength = strength, .bid = bid });
    }

    return hands;
}

/// Rank each hand and multiply by the bid to get the score for the hand and then sum
///
fn calculateHandScore(hands: *HandsList) !usize {
    var hs = try hands.toOwnedSlice();
    std.mem.sort(Hand, hs, {}, sortHandByStrengthAsc);

    var sum: usize = 0;
    for (hs, 0..) |h, i| {
        sum += (i + 1) * h.bid;
    }

    return sum;
}

/// Packs the strength into a single u32. The most significant bits store the type
/// Regular poker hands
///
fn calculateHandStrengthPart1(cards: []const u8) u32 {
    var strength: u32 = 0;

    var num_each = [_]u8{0} ** 13;

    for (cards, 0..) |c, i| {
        const val: u32 = switch (c) {
            'A' => 12,
            'K' => 11,
            'Q' => 10,
            'J' => 9,
            'T' => 8,
            else => c - '0' - 2,
        };

        //We can store the value in 4bits as the max is 12
        const offset: u5 = @intCast((4 - i) * 4);
        strength |= val << offset;

        //Count the number of each card and we can use that to score the type of the hand
        num_each[val] += 1;
    }

    //Sort the cards so we can see if we have any five of a kinds, etc
    std.mem.sort(u8, &num_each, {}, std.sort.desc(u8));

    const hand_type: u32 = switch (num_each[0]) {
        5 => 6, //check for 5 of a kind
        4 => 5, //check for 4 of a kind
        3 => if (num_each[1] == 2) 4 else 3, //check for full house or 3 of a kind
        2 => if (num_each[1] == 2) 2 else 1, //check for 2 pairs or 1 pair
        else => 0, //no special hand - high card wins
    };

    //A known type modifies the strength and takes precedent
    strength |= hand_type << 20;

    return strength;
}

/// Packs the strength into a single u32. The most significant bits store the type
/// Jacks are replaced with Jokers which are low scoring but can transform to make a strong hand e.g "KKKJ2" => 4 of a kind
///
fn calculateHandStrengthPart2(cards: []const u8) u32 {
    var strength: u32 = 0;

    var num_each = [_]u8{0} ** 13;
    var num_jokers: u32 = 0;

    for (cards, 0..) |c, i| {
        const val: u32 = switch (c) {
            'A' => 12,
            'K' => 11,
            'Q' => 10,
            'T' => 9,
            'J' => 0,
            else => c - '0' - 1,
        };

        //We can store the value in 4bits as the max is 12
        const offset: u5 = @intCast((4 - i) * 4);
        strength |= val << offset;

        //Count the number of each card and we can use that to score the type of the hand
        if (val > 0) {
            num_each[val] += 1;
        } else {
            num_jokers += 1;
        }
    }

    //Sort the cards so we can see if we have any five of a kinds, etc
    std.mem.sort(u8, &num_each, {}, std.sort.desc(u8));

    const hand_type: u32 = switch (num_each[0] + num_jokers) {
        5 => 6, //check for 5 of a kind
        4 => 5,
        3 => if (num_each[1] == 2) 4 else 3, //check for full house or 3 of a kind
        2 => if (num_each[1] == 2) 2 else 1, //check for 2 pairs or 1 pair
        else => 0, //no special hand - high card wins
    };

    //A known type modifies the strength and takes precedent
    strength |= hand_type << 20;

    return strength;
}

fn sortHandByStrengthAsc(context: void, a: Hand, b: Hand) bool {
    return std.sort.asc(u32)(context, a.strength, b.strength);
}
