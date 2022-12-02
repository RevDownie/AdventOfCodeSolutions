const std = @import("std");

const input_file = @embedFile("input.txt");

/// Advent of code - Day 2
///
/// Part 1 - Rock, paper scissors - run through the input calculatng the score based on what is played and the
/// Part 2 - Turns out the second column is the result so you need to calculate the hand needed to achieve the result
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const result_1 = try calculateScoreTwoHands(input_file[0..]);
    const result_2 = try calculateScoreHandAndResult(input_file[0..]);
    std.debug.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Data is in the format 'A X\n' with each turn on a new line. A = Rock, B = Paper, C = Scissors for them and XYZ equiavlent for us
/// Calculate the score based on XYZ => 123 and Win = 6, Draw = 3, Loss = 0
///
fn calculateScoreTwoHands(data: []const u8) !u32 {
    var total_score: u32 = 0;

    var i: usize = 0;
    while (i < data.len) {
        const them = data[i];
        const us = data[i + 2] - 23;
        const result = determineResult(them, us);
        total_score += getResultScore(result);
        total_score += getHandScore(us);

        i += 4; //Skip new line
    }

    return total_score;
}

/// Data is in the format 'A X\n' with each turn on a new line. A = Rock, B = Paper, C = Scissors for them and XYZ is the result we need to achieve
/// Calculate the score based on ABC for us => 123 and Win = 6, Draw = 3, Loss = 0
///
fn calculateScoreHandAndResult(data: []const u8) !u32 {
    var total_score: u32 = 0;

    var i: usize = 0;
    while (i < data.len) {
        const them = data[i];
        const result = data[i + 2];
        const us = determineHandToAchieveResult(them, result);
        std.debug.print("T: {}, U: {}, R: {}\n", .{them, us, result});
        total_score += getResultScore(result);
        total_score += getHandScore(us);

        i += 4; //Skip new line
    }

    return total_score;
}

/// Rock paper scisssors to return X for loss, Y for draw, Z for win
///
fn determineResult(them: u8, us: u8) u8 {
    if (us == them) {
        //Draw
        return 'Y';
    }

    //Rock beats scissors
    if (us == 'A' and them == 'C') {
        //Win
        return 'Z';
    }

    //Paper beats rock
    if (us == 'B' and them == 'A') {
        //Win
        return 'Z';
    }

    //Scissors beats paper
    if (us == 'C' and them == 'B') {
        //Win
        return 'Z';
    }

    return 'X';
}

/// Convert A,B,C into 1,2,3
///
inline fn getHandScore(hand: u8) u32 {
    return @as(u32, hand - 'A') + 1;
}

/// Convert X,Y,Z into 0,3,6
///
inline fn getResultScore(result: u8) u32 {
    return @as(u32, result - 'X') * 3;
}

/// Given a result and the opponents hand find the hand that achieves the result
/// X = Loss, Y = Draw, Z = Win
/// A = rock, B = paper, C = scissors
///
fn determineHandToAchieveResult(them: u8, result: u8) u8 {
    //Loss equation +2 wrap A => C, B => A, C => B
    if (result == 'X') {
        return 'A' + ((them - 'A' + 2) % 3);
    }

    //Draw
    if (result == 'Y') {
        return them;
    }

    //Win equation =+ wrap A => B, B => C, C => A
    return 'A' + ((them - 'A' + 1) % 3);
}
