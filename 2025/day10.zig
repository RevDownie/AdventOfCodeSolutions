const std = @import("std");

const input_file = @embedFile("input_day10.txt");

pub fn Queue(comptime T: type) type {
    return struct {
        const Self = @This();

        buf: []T,
        head: usize = 0,
        tail: usize = 0,
        count: usize = 0,

        pub fn init(allocator: std.mem.Allocator, capacity: usize) !Self {
            return .{
                .buf = try allocator.alloc(T, capacity),
            };
        }

        pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
            allocator.free(self.buf);
        }

        pub fn isEmpty(self: *Self) bool {
            return self.count == 0;
        }

        pub fn enqueue(self: *Self, item: T) !void {
            if (self.isFull()) return error.QueueFull;

            self.buf[self.tail] = item;
            self.tail = (self.tail + 1) % self.buf.len;
            self.count += 1;
        }

        pub fn dequeue(self: *Self) !T {
            if (self.isEmpty()) return error.QueueEmpty;

            const item = self.buf[self.head];
            self.head = (self.head + 1) % self.buf.len;
            self.count -= 1;
            return item;
        }
    };
}

/// Advent of code - Day 10
///
/// Part 1 - Find the fewest number of button presses to achieve the given light sequence.
/// Part 2 -
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const result = try run(input_file[0..], gpa.allocator());
    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result.p1, result.p2, duration / 1000000.0 });
}

fn run(data: []const u8, allocator: std.mem.Allocator) !struct { p1: u64, p2: u64 } {
    var buttons = try std.ArrayList(u16).initCapacity(allocator, 100);
    defer buttons.deinit(allocator);

    var total_1: u64 = 0;

    var line_it = std.mem.tokenizeScalar(u8, data, '\n');
    while (line_it.next()) |line| {
        var space_it = std.mem.tokenizeScalar(u8, line, ' ');
        const light_mask = convertLightDiagramToBitmask(space_it.next().?); //First block is the light diagram, convert it to a mask

        while (space_it.next()) |button| {
            const button_mask = convertButtonToBitmask(button);
            try buttons.append(allocator, button_mask);
        }

        //Run a search looking for the combinations of buttons that when XORd create the light diagram
        const num_presses = try searchForButtonCombination(light_mask, buttons.items[0 .. buttons.items.len - 1], allocator); //Trim off the last set which is the "Joltage"
        total_1 += num_presses;

        buttons.clearRetainingCapacity();
    }

    return .{ .p1 = total_1, .p2 = 0 };
}

/// Iterate the combinations. We XOR the buttons together
/// Use BFS as that will give us the lowest button count compared to DFS
fn searchForButtonCombination(light_mask: u16, button_masks: []const u16, allocator: std.mem.Allocator) !u16 {
    const Data = struct {
        state: u16,
        depth: u16,
    };

    var visited = try allocator.alloc(bool, 1 << 16);
    defer allocator.free(visited);
    @memset(visited, false);

    var queue = try Queue(Data).init(allocator, 1 << 16);
    defer queue.deinit(allocator);

    //Start from all lights off
    try queue.enqueue(.{ .state = 0, .depth = 0 });
    visited[0] = true;

    while (!queue.isEmpty()) {
        const node = try queue.dequeue();

        if (node.state == light_mask) {
            return node.depth;
        }

        //Try pressing each button once more
        for (button_masks) |m| {
            const next_state = node.state ^ m;
            if (!visited[next_state]) {
                visited[next_state] = true;
                try queue.enqueue(.{ .state = next_state, .depth = node.depth + 1 });
            }
        }
    }

    return 0;
}

/// Trim off the surrounding brackets and convert to a bit mask where # is 1 and . is 0
fn convertLightDiagramToBitmask(diagram: []const u8) u16 {
    var mask: u16 = 0;
    var bit: u4 = 0;

    for (diagram[1 .. diagram.len - 1]) |c| {
        if (c == '#') {
            mask |= @as(u16, 1) << bit;
        }

        bit += 1;
    }

    return mask;
}

/// Trim off the surrounding brackets and then convert to a mask where each index specified by the button is 1
fn convertButtonToBitmask(button: []const u8) u16 {
    var mask: u16 = 0;

    for (button[1 .. button.len - 1]) |c| {
        if (c != ',') {
            const bit_idx: u4 = @intCast(c - '0');
            mask |= @as(u16, 1) << bit_idx;
        }
    }

    return mask;
}
