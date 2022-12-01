const std = @import("std");
const io = std.io;
const fs = std.fs;

const input_file = @embedFile("input.txt");

/// Advent of code - Day 1
///
/// Part 1 - Input is a list of calories separated into blocks per elf. Find the total calories carried by the elf with the most calories
///
pub fn main() !void {
    const most_calories = try partOne(input_file[0..]);
    std.debug.print("Part One {}\n", .{most_calories});
}

/// Find the total calories being carried by the elf with the most calories
/// Each new line is a calorie number, blank lines separate the elves
///
fn partOne(data: []const u8) !u32 {
    var current_elf_total: u32 = 0;
    var max_elf_total: u32 = 0;

    var i: usize = 0;
    while (i < data.len) {
        var j = i;
        while (data[j] != '\n') : (j += 1) {} //Skip to the end of the first digit
        const cals = try std.fmt.parseUnsigned(u32, data[i..j], 10);
        current_elf_total += cals;
        i = j + 1;

        //Check if we are at a new elf block or at the end of the file
        if (i >= data.len or data[i] == '\n') {
            i += 1; //Skip the new line block

            if (current_elf_total > max_elf_total) {
                max_elf_total = current_elf_total;
            }
            current_elf_total = 0;
        }
    }

    return max_elf_total;
}
