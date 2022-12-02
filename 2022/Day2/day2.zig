const std = @import("std");

const input_file = @embedFile("input.txt");

/// Advent of code - Day 2
///
/// Part 1 - Rock, paper scissors - run through the input calculatng the score based on what is played and the result
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const result_1 = try calculateScore(input_file[0..]);
    std.debug.print("Part 1: {}, Part 2: ?? ms: {}\n", .{ result_1, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Data is in the format 'A X\n' with each turn on a new line. A = Rock, B = Paper, C = Scissors for them and XYZ equiavlent for us
/// Calculate the score based on XYZ => 123 and Win = 6, Draw = 3, Loss = 0
///
fn calculateScore(data: []const u8) !u32 {
    var total_score: u32 = 0;

    var i: usize = 0;
    while (i < data.len) {
        const them = data[i];
        const us = data[i + 2];
        total_score += calculateResultScore(them, us);
        total_score += getHandScore(us);

        i += 4; //Skip new line
    }

    return total_score;
}

/// Rock paper scisssors calculate score for us vs them
///
fn calculateResultScore(them: u8, us: u8) u32 {
    if ((us - 23) == them) {
        //Draw
        return 3;
    }

    //Rock beats scissors
    if (us == 'X' and them == 'C') {
        //Win
        return 6;
    }

    //Paper beats rock
    if (us == 'Y' and them == 'A') {
        //Win
        return 6;
    }

    //Scissors beats paper
    if (us == 'Z' and them == 'B') {
        //Win
        return 6;
    }

    return 0;
}

/// Convert X,y,z into 1,2,3
///
fn getHandScore(hand: u8) u32 {
    return switch (hand) {
        'X' => 1,
        'Y' => 2,
        'Z' => 3,
        else => unreachable,
    };
}
