const std = @import("std");
const io = std.io;
const fs = std.fs;

const required_field_hashes = [_]usize{
    field_hash("byr"),
    field_hash("iyr"),
    field_hash("eyr"),
    field_hash("hgt"),
    field_hash("hcl"),
    field_hash("ecl"),
    field_hash("pid"),
    //field_hash("cid"),
};

/// Advent of code - Day 4
///
/// Part 1 - Parse "passport" key value format looking for missing fields and counting valid passports
///
pub fn main() !void {
    const input_file = try fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    //Using my knowledge of the file size and length to define the buffer sizes
    var input_buffer: [20 * 1024]u8 = undefined;
    const input_len = try input_file.readAll(&input_buffer);

    var valid_count: usize = 0;

    //40 is the size of the hash range
    var set: [40]bool = undefined;

    var i: usize = 0;
    while (i < input_len - 1) : (i += 1) {
        if (input_buffer[i] == ':') {
            set[field_hash(input_buffer[i - 3 .. i])] = true;
        } else if (input_buffer[i] == '\n' and input_buffer[i + 1] == '\n') {
            //Blank line means new passport entry. Check if the previous one was valid - had all required fields
            const valid = validate_and_clear_fields(required_field_hashes[0..], set[0..]);
            if (valid == true) {
                valid_count += 1;
            }
        }
    }

    //Catch the final passport
    const valid = validate_and_clear_fields(required_field_hashes[0..], set[0..]);
    if (valid == true) {
        valid_count += 1;
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Part 1: {}, Part 2: {}\n", .{ valid_count, "TODO" });
}

/// Field sum to unique numbers in the range 304 - 340 so we can map to a smaller hash range
/// rather than doing a fancy hash
///
fn field_hash(field: []const u8) usize {
    return (@as(usize, field[0]) + @as(usize, field[1]) + @as(usize, field[2])) - 304;
}

/// Returns if the set has the required number of fields and resets the fields
///
fn validate_and_clear_fields(field_hashes: []const usize, field_set: []bool) bool {
    var num_fields: usize = 0;
    for (field_hashes) |h| {
        if (field_set[h] == true) {
            num_fields += 1;
        }

        field_set[h] = false;
    }

    return num_fields == field_hashes.len;
}
