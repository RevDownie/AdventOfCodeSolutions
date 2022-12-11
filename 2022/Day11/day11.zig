const std = @import("std");

const input_file = @embedFile("input.txt");

const NUM_MONKEYS = 8;

const MonkeyData = struct {
    current_worries: std.TailQueue(usize),
    operation: *const fn (usize, usize) usize,
    op_val: usize,
    test_divisor: usize,
    pass_destination: usize,
    fail_destination: usize,
};

/// Advent of code - Day 11
///
/// Part 1 - Moving items between monkeys in rounds based on monkeys' decision criteria
/// Part 2 - 10000 rounds a no division - means it will exceed max int sizes
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var node_pool = std.ArrayList(*std.TailQueue(usize).Node).init(gpa.allocator());
    defer {
        for (node_pool.items) |n| {
            gpa.allocator().destroy(n);
        }
        node_pool.deinit();
    }

    var monkeys = try buildInitialState(input_file[0..], gpa.allocator(), &node_pool);
    const result_1 = try runSimulation(monkeys[0..], undefined, 20, 1);

    //Part 2 the numbers are so large they exceed capacity - but they are all prime numbers so can be modulo'd to be smaller
    var monkeys_2 = try buildInitialState(input_file[0..], gpa.allocator(), &node_pool);
    var global_mod: usize = 1;
    for (monkeys) |m| {
        global_mod *= m.test_divisor;
    }
    const result_2 = try runSimulation(monkeys_2[0..], global_mod, 10000, 2);

    std.debug.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Parse the input data into Monkey Data
///Monkey 0:
///  Starting items: 79, 98
///  Operation: new = old * 19
///  Test: divisible by 23
///    If true: throw to monkey 2
///    If false: throw to monkey 3
///
fn buildInitialState(data: []const u8, allocator: std.mem.Allocator, node_pool: *std.ArrayList(*std.TailQueue(usize).Node)) ![NUM_MONKEYS]MonkeyData {
    var monkeys: [NUM_MONKEYS]MonkeyData = undefined;
    var monkey_idx: usize = 0;
    var lines = std.mem.tokenize(u8, data, "\n");

    while (monkey_idx < NUM_MONKEYS) : (monkey_idx += 1) {
        _ = lines.next(); //Don't need the first line as monkeys are in order

        //Parse the starting items
        var starting_items_line = lines.next().?;
        var queue = std.TailQueue(usize){};

        var num_it = std.mem.split(u8, starting_items_line[18..], ", ");
        while (num_it.next()) |num| {
            var node_ptr = try allocator.create(std.TailQueue(usize).Node);
            node_ptr.* = std.TailQueue(usize).Node{ .data = try std.fmt.parseUnsigned(u32, num, 10) };
            queue.append(node_ptr);
            try node_pool.*.append(node_ptr);
        }

        //Parse the operation
        var operation_line = lines.next().?;
        var op_fn: *const fn (usize, usize) usize = undefined;
        var op_val: usize = undefined;
        switch (operation_line[23]) {
            '+' => {
                if (operation_line[25] == 'o') {
                    op_fn = &opAddSelf;
                } else {
                    op_fn = &opAdd;
                    op_val = try std.fmt.parseUnsigned(u32, operation_line[25..], 10);
                }
            },
            '*' => {
                if (operation_line[25] == 'o') {
                    op_fn = &opMulSelf;
                } else {
                    op_fn = &opMul;
                    op_val = try std.fmt.parseUnsigned(u32, operation_line[25..], 10);
                }
            },
            else => @panic("Unknown operator"),
        }

        //Parse the test
        var test_line = lines.next().?;
        const test_divisor = try std.fmt.parseUnsigned(usize, test_line[21..], 10);

        //Parse the destinations
        var true_line = lines.next().?;
        const true_dest = true_line[29] - '0';
        var false_line = lines.next().?;
        const false_dest = false_line[30] - '0';

        //Package up and move to the next
        monkeys[monkey_idx] = MonkeyData{
            .current_worries = queue,
            .operation = op_fn,
            .op_val = op_val,
            .test_divisor = test_divisor,
            .pass_destination = true_dest,
            .fail_destination = false_dest,
        };
    }

    return monkeys;
}

/// From Monkey 1 to N, dequeue each item, apply the scoring, apply the /3 truncate factor, check the divisible by criteria and
/// enqueue on another monkey
///
/// Run for R rounds and then return the number of decision of top 2 monkeys multiplied together
///
fn runSimulation(monkeys: []MonkeyData, global_mod: usize, comptime num_rounds: u32, comptime part: u8) !usize {
    var decision_counts = [_]usize{0} ** NUM_MONKEYS;
    var i: usize = 0;
    while (i < num_rounds) : (i += 1) {
        for (monkeys) |*m, m_idx| {
            while (m.*.current_worries.popFirst()) |node| {
                node.data = m.*.operation(node.data, m.*.op_val);
                switch (part) {
                    1 => node.data /= 3,
                    2 => node.data %= global_mod,
                    else => unreachable,
                }

                if (node.data % m.*.test_divisor == 0) {
                    monkeys[m.*.pass_destination].current_worries.append(node);
                } else {
                    monkeys[m.*.fail_destination].current_worries.append(node);
                }

                decision_counts[m_idx] += 1;
            }
        }
    }

    //Find the max 2 and multiply
    var max_1: usize = 0;
    var max_2: usize = 0;
    for (decision_counts) |n| {
        if (n > max_2) {
            max_1 = max_2;
            max_2 = n;
        } else if (n > max_1) {
            max_1 = n;
        }
    }
    return max_1 * max_2;
}

fn opAdd(old: usize, v: usize) usize {
    return old + v;
}

fn opMul(old: usize, v: usize) usize {
    return old * v;
}

fn opAddSelf(old: usize, _: usize) usize {
    return old + old;
}

fn opMulSelf(old: usize, _: usize) usize {
    return old * old;
}
