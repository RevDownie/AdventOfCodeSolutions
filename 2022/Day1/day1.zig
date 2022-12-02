const std = @import("std");

const input_file = @embedFile("input.txt");

/// Advent of code - Day 1
///
/// Part 1 - Input is a list of calories separated into blocks per elf. Find the total calories carried by the elf with the most calories
/// Part 2 - Pt1 found the total of elf with the most calories, pt2 wants the total for the top 3.
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const most_calories = try findTop3MostCalories(input_file[0..]);

    const result_1 = most_calories[0];
    const result_2 = most_calories[0] + most_calories[1] + most_calories[2];
    std.debug.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Find the total calories being carried by the elf with the most calories
/// Each new line is a calorie number, blank lines separate the elves
///
fn findTop3MostCalories(data: []const u8) ![3]u32 {
    var current_elf_total: u32 = 0;
    var max_elf_total = [3]u32{ 0, 0, 0 };

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

            //Replace the lowest number that this is greater than
            var lowest_greatest: u32 = 9999999;
            var lowest_greatest_idx: usize = 0;
            for (max_elf_total) |v, idx| {
                if (lowest_greatest >= v) {
                    lowest_greatest = v;
                    lowest_greatest_idx = idx;
                }
            }

            if (current_elf_total > lowest_greatest) {
                max_elf_total[lowest_greatest_idx] = current_elf_total;
            }
            current_elf_total = 0;
        }
    }

    //Sort so that 0 is the highest
    //TODO: Change so we keep a running sorted list
    std.sort.sort(u32, max_elf_total[0..], {}, comptime std.sort.desc(u32));
    return max_elf_total;
}
