const std = @import("std");
const io = std.io;
const fs = std.fs;

const input_file = @embedFile("input.txt");

const paper_dims = 1500; //From the data
const paper_area = paper_dims * paper_dims;

/// Advent of code - Day 13
///
/// Part 1 - Paper folds - essentially count the number of dots left after the paper is folded once assuming that overlapping dots combine
/// Part 2 - Complete all folds and the dots should show a number when the grid is printed
///
pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const timer = std.time.Timer;
    const t = try timer.start();

    var data_cursor: usize = 0;
    const paper = try build_paper(input_file[0..], &data_cursor);

    while (input_file[data_cursor] != 'f') : (data_cursor += 1) {} //Skip to the fold instructions

    var paper_1 = paper;
    try fold(&paper_1, input_file[data_cursor..], 1);

    var paper_2 = paper;
    try fold(&paper_2, input_file[data_cursor..], 0xFFFFFFFF);

    const result_1 = paper_1.count();
    try stdout.print("Part 1: {}, Part 2: See Below ms: {}\n", .{ result_1, @intToFloat(f64, t.read()) / 1000000.0 });
    try print_grid(paper_2);
}

fn build_paper(input_data: []const u8, data_cursor: *usize) !std.StaticBitSet(paper_area) {
    var paper = std.StaticBitSet(paper_area).initEmpty();

    var i = data_cursor.*;
    while (i < input_data.len) {
        var j = i;
        while (input_data[j] != ',') : (j += 1) {} //Skip to the end of the first digit
        const x = try std.fmt.parseUnsigned(u32, input_data[i..j], 10);
        i = j + 1;
        j += 2;

        while (input_data[j] != '\n') : (j += 1) {} //Skip to the end of the second digit
        const y = try std.fmt.parseUnsigned(u32, input_data[i..j], 10);
        i = j + 1;

        const paper_idx = y * paper_dims + x;
        paper.set(paper_idx);

        if (input_data[i] == '\n') {
            break;
        }
    }

    data_cursor.* = i;
    return paper;
}

/// Did think about not using the grid and just finding symmetrical dots but I suspect part 2 is an image so will end
/// up with a grid anyway
///
fn fold(paper: *std.StaticBitSet(paper_area), fold_instructions_data: []const u8, max_folds: u32) !void {
    var folds: u32 = 0;

    var instruction_it = std.mem.split(fold_instructions_data, "\n");
    while (instruction_it.next()) |instruction| {
        //fold along x=5 => Can skip the 11 characters until we get to X or Y
        const direction = instruction[11];
        const value = try std.fmt.parseUnsigned(u32, instruction[13..], 10);
        var dots = paper.*.iterator(.{});

        if (direction == 'x') {
            while (dots.next()) |dot| {
                const x = dot % paper_dims;
                const y = dot / paper_dims;

                if (x < value) {
                    continue;
                }

                const newX = value - (x - value);
                paper.set(y * paper_dims + newX);
                paper.unset(dot);
            }
        } else if (direction == 'y') {
            while (dots.next()) |dot| {
                const x = dot % paper_dims;
                const y = dot / paper_dims;

                if (y < value) {
                    continue;
                }

                const newY = value - (y - value);
                paper.set(newY * paper_dims + x);
                paper.unset(dot);
            }
        }

        folds += 1;

        if (folds == max_folds) {
            return;
        }
    }
}

fn print_grid(paper: std.StaticBitSet(paper_area)) !void {
    const stdout = std.io.getStdOut().writer();

    //Calculate the width and height of the folded paper
    var width: usize = 0;
    var height: usize = 0;
    var dots = paper.iterator(.{});
    while (dots.next()) |dot| {
        const x = dot % paper_dims;
        const y = dot / paper_dims;

        if (x > width) {
            width = x;
        }

        if (y > height) {
            height = y;
        }
    }

    var y: usize = 0;
    while (y <= height) : (y += 1) {
        var x: usize = 0;
        while (x <= width) : (x += 1) {
            if (paper.isSet(y * paper_dims + x)) {
                try stdout.print("*", .{});
            } else {
                try stdout.print(" ", .{});
            }
        }
        try stdout.print("\n", .{});
    }
}
