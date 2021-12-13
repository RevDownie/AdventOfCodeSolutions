const std = @import("std");
const io = std.io;
const fs = std.fs;

/// Advent of code - Day 8
///
/// Part 1 - Find all the numbers in the output section that correspond to 1,4,7 and 8 - i.e. have sequence length matching 2,4,3,7
/// Part 2 - Decode all the numbers and then concat the output numbers
///
pub fn main() !void {
    const input_file = try fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    //Using my knowledge of the file size and length to define the buffer sizes
    var input_buffer: [1024 * 17]u8 = undefined;
    const input_len = try input_file.readAll(&input_buffer);

    const stdout = std.io.getStdOut().writer();
    const timer = std.time.Timer;

    const t = try timer.start();
    const result_1 = count_uniquely_segmented_digits_in_output(input_buffer[0..input_len]);
    const result_2 = decode_output(input_buffer[0..input_len]);
    try stdout.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

fn count_uniquely_segmented_digits_in_output(input_buffer: []u8) u32 {
    var total: u32 = 0;
    var i: usize = 0;
    full_loop: while (true) { //Loop over the full input

        while (input_buffer[i] != '|') : (i += 1) {} //Skip to the output
        i += 2;

        output_loop: while (true) : (i += 1) { //Loop over the output
            var seq_len: u32 = 0;
            while (input_buffer[i] != ' ' and input_buffer[i] != '\n') : (i += 1) { //Count the sequence length breaking on spaces
                seq_len += 1;
            }

            if (seq_len == 2 or seq_len == 4 or seq_len == 3 or seq_len == 7) { //Unique segments count for the digits - 1,4,7,8
                total += 1; //Sum all the "unique" digit counts
            }

            if (i >= input_buffer.len - 1) {
                break :full_loop;
            }

            if (input_buffer[i] == '\n') { //End of the line - jump to the next output
                break :output_loop;
            }
        }
    }

    return total;
}

/// ----- RULES
/// We can identiyf 1,4,7,8 immediately from unique segment count
/// We can then identify 6,3 as soon as we have identified 1 from segment count and that they have a+b or a|b
/// From 6 we know whether a or b is lower and can identify 5,2
/// From 5 we can identify g as bottom left and can identify 9,0
///
fn decode_output(input_buffer: []u8) u32 {
    var total: u32 = 0;

    var i: usize = 0;
    while (i < input_buffer.len) {

        //Start at the input and loop through to build the data needed to decode
        //we are looking for the bottom left, top right and bottom right segement Ids
        //this coupled with the segment lengths is enough to solve
        const input_start = i;
        var r: [2]u8 = undefined;
        var br: u8 = 0;
        var tr: u8 = 0;
        var bl: u8 = 0;

        keystone_loop: while (true) {
            var seq_len: u32 = 0;
            while (input_buffer[i] != ' ') : (i += 1) { //Count the sequence length breaking on spaces
                seq_len += 1;
            }

            try_extract_keystones(input_buffer[i - seq_len .. i], &r, &tr, &br, &bl);

            //We have everything we need to decode output
            if (br > 0 and bl > 0 and tr > 0) {
                break :keystone_loop;
            }

            i += 1; // Skip the space

            //Reached the end of this input - loop again as we need another pass to get the keystones
            if (input_buffer[i] == '|') {
                i = input_start;
            }
        }

        while (input_buffer[i] != '|') : (i += 1) {}
        i += 2; //Skip the space

        //We now have everything we need to decode - loop over the output and decode it
        var output: [4]u32 = undefined;
        var output_idx: usize = 0;
        output_loop: while (true) : (i += 1) { //Loop over the output
            var seq_len: u32 = 0;
            while (input_buffer[i] != ' ' and input_buffer[i] != '\n') : (i += 1) { //Count the sequence length breaking on spaces
                seq_len += 1;
            }

            output[output_idx] = decode_digit(input_buffer[i - seq_len .. i], tr, br, bl);
            output_idx += 1;

            if (input_buffer[i] == '\n') { //End of the line - jump to the next output
                total += to_base_10(output);
                i += 1;
                break :output_loop;
            }
        }
    }

    return total;
}

/// The keystones are the TL, BR, BL segments as we can use the length and these to decode the numbers
///
fn try_extract_keystones(chars: []u8, r: *[2]u8, tr: *u8, br: *u8, bl: *u8) void {
    switch (chars.len) {
        2 => {
            //Represents the number 1 but we don't know segment is top/bottom
            //Store both and we can figure out when we get more info
            r[0] = chars[0];
            r[1] = chars[1];
        },

        6 => {
            var res_contains: u8 = 0;
            var res_notcontains: u8 = 0;
            if (xor_contains(chars, r[0], r[1], &res_contains, &res_notcontains)) {
                //Represents the number 6 - whichever segemnt it has out of r represents br and the other is tr
                br.* = res_contains;
                tr.* = res_notcontains;
            }
        },

        5 => {
            var res_contains: u8 = 0;
            var res_notcontains: u8 = 0;
            if (xor_contains(chars, br.*, tr.*, &res_contains, &res_notcontains) and res_contains == br.*) {
                //Represents the number 5 - whichever segment is missing other than tr reprsents bl
                bl.* = find_missing_segment(chars, tr.*);
            }
        },
        3, 4, 7 => {},
        else => unreachable,
    }
}

/// Use thr number of segments and the keystones to decode
///
fn decode_digit(chars: []u8, tr: u8, br: u8, bl: u8) u32 {
    var decoded: u32 = undefined;

    switch (chars.len) {
        2 => decoded = 1,
        3 => decoded = 7,
        4 => decoded = 4,
        7 => decoded = 8,
        5 => {
            if (contains(chars, bl) == true) {
                decoded = 2;
            } else if (contains(chars, tr) == true) {
                decoded = 3;
            } else {
                decoded = 5;
            }
        },
        6 => {
            if (contains(chars, bl) == false) {
                decoded = 9;
            } else if (contains(chars, tr) == false) {
                decoded = 6;
            } else {
                decoded = 0;
            }
        },
        else => unreachable,
    }

    return decoded;
}

fn contains(chars: []u8, a: u8) bool {
    for (chars) |c| {
        if (c == a) {
            return true;
        }
    }

    return false;
}

fn xor_contains(chars: []u8, a: u8, b: u8, contained: *u8, not_contained: *u8) bool {
    var contains_a = false;
    var contains_b = false;
    for (chars) |c| {
        if (c == a) {
            contains_a = true;
        } else if (c == b) {
            contains_b = true;
        }
    }

    if (contains_a == true and contains_b == false) {
        contained.* = a;
        not_contained.* = b;
        return true;
    }

    if (contains_a == false and contains_b == true) {
        contained.* = b;
        not_contained.* = a;
        return true;
    }

    return false;
}

fn find_missing_segment(chars: []u8, except: u8) u8 {
    const segments = [_]u8{ 'a', 'b', 'c', 'd', 'e', 'f', 'g' };
    for (segments) |s| {
        var found = false;
        for (chars) |c| {
            if (c == s) {
                found = true;
                break;
            }
        }

        if (found == false and s != except) {
            return s;
        }
    }

    unreachable;
}

fn to_base_10(digits: [4]u32) u32 {
    return digits[0] * 1000 + digits[1] * 100 + digits[2] * 10 + digits[3];
}
