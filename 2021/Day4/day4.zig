const std = @import("std");
const io = std.io;
const fs = std.fs;

const ValIndex = struct {
    val: u32,
    idx: usize,
};

const win_eval_fn = fn (max_turns: []u32) ValIndex;
const num_boards = 100;
const board_dims = 5;
const board_area = board_dims * board_dims;

/// Advent of code - Day 4
///
/// Part 1 - Bingo (rows and cols)
/// Part 2 - As part one but the board that is last to win rather than first
///
pub fn main() !void {
    const input_file = try fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    //Using my knowledge of the file size and length to define the buffer sizes
    var input_buffer: [1024 * 13]u8 = undefined;
    const input_len = try input_file.readAll(&input_buffer);

    const stdout = std.io.getStdOut().writer();
    const timer = std.time.Timer;

    const t = try timer.start();
    const result_1 = bingo(input_buffer[0..input_len], win_first);
    const result_2 = bingo(input_buffer[0..input_len], win_last_by_board);

    try stdout.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Perhaps a simpler way to approach this - if we parse the boards and map each number to the order the number was called out
/// then for each row and col find the max number (which tells us if we had played to the end which turn this row or column completes on)
/// The min order number from all those maxes tells us the row or col which completed first and ultimately the turn on which it won
/// we can then iterate the boards again and sum the "unmarked" which are any numbers called after the winning turn
///
fn bingo(input_buffer: []u8, winning_turn_fn: win_eval_fn) !u32 {
    const allocator = std.heap.page_allocator;

    var called_numbers: [100]u32 = undefined;
    var called_num_to_turn = [_]u32{0xFFFFFFFF} ** 100;

    var boards = try allocator.alloc(u32, num_boards * board_area);
    defer allocator.free(boards);

    //Parse call order
    var i: usize = 0;
    var num_idx: u32 = 0;
    while (input_buffer[i] != '\n') {
        var j: usize = i;
        while (input_buffer[j] != ',' and input_buffer[j] != '\n') : (j += 1) {} //Peek ahead looking for the end of the number

        const call_num = try std.fmt.parseUnsigned(u32, input_buffer[i..j], 10);
        called_numbers[num_idx] = call_num;
        called_num_to_turn[call_num] = num_idx;
        num_idx += 1;
        i = j + 1;
    }

    //Parse boards
    num_idx = 0;
    while (i < input_buffer.len) {
        while (input_buffer[i] == ' ' or input_buffer[i] == '\n') : (i += 1) {}
        var j: usize = i;
        while (input_buffer[j] != ' ' and input_buffer[j] != '\n') : (j += 1) {} //Peek ahead looking for the end of the number

        const board_num = try std.fmt.parseUnsigned(u32, input_buffer[i..j], 10);
        boards[num_idx] = board_num;
        num_idx += 1;
        i = j + 1;
    }

    //Convert each number to when it was called and find the max for each row and col
    //The min of those maxes gives us the call where house was won - everything after that would theoretically be uncalled
    //as the game would stop
    var max_turns = try allocator.alloc(u32, board_dims * 2 * num_boards);
    defer allocator.free(max_turns);
    for (max_turns) |m, idx| {
        max_turns[idx] = 0;
    }

    const col_buf_offset = max_turns.len / 2;
    for (boards) |n, idx| {
        const row = idx / board_dims;
        const col = idx % board_dims;
        const turn = called_num_to_turn[n];
        if (turn > max_turns[row]) {
            max_turns[row] = turn;
        }

        const board_col = col + board_dims * (row / board_dims);
        if (turn > max_turns[col_buf_offset + board_col]) {
            max_turns[col_buf_offset + board_col] = turn;
        }
    }

    const winning_turn = winning_turn_fn(max_turns[0..]);
    const winning_board = if (winning_turn.idx < col_buf_offset) winning_turn.idx / board_dims else (winning_turn.idx - col_buf_offset) / board_dims;
    const board_offset = winning_board * board_area;
    const called_number = called_numbers[winning_turn.val];
    const uncalled_total = sum_uncalled(boards[board_offset .. board_offset + board_area], called_num_to_turn[0..], winning_turn.val);

    return called_number * uncalled_total;
}

/// Sum all values that were called after the winning turn
///
fn sum_uncalled(boards: []u32, called_num_to_turn: []u32, max_turn: u32) u32 {
    var sum: u32 = 0;
    for (boards) |n| {
        if (called_num_to_turn[n] > max_turn) {
            sum += n;
        }
    }
    return sum;
}

/// First row or col to complete wins for that board
///
fn win_first(vals: []u32) ValIndex {
    var min: u32 = 0xFFFFFFFF;
    var minIdx: usize = 0;
    for (vals) |v, i| {
        if (v <= min) {
            min = v;
            minIdx = i;
        }
    }

    return ValIndex{ .val = min, .idx = minIdx };
}

/// Last board to complete wins
///
fn win_last_by_board(max_turns: []u32) ValIndex {
    //Find the min or col or row for each board and then find the max
    var min_by_board: [num_boards]ValIndex = undefined;
    for (min_by_board) |m, i| {
        const row_offset = i * board_dims;
        var row = win_first(max_turns[row_offset .. row_offset + board_dims]);
        row.idx += row_offset;
        const col_offset = row_offset + (max_turns.len / 2);
        var col = win_first(max_turns[col_offset .. col_offset + board_dims]);
        col.idx += col_offset;
        min_by_board[i] = if (row.val < col.val) row else col;
    }

    var max = ValIndex{ .val = 0, .idx = 0 };
    for (min_by_board) |m| {
        if (m.val >= max.val) {
            max = m;
        }
    }

    return max;
}
