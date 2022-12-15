const std = @import("std");

const input_file = @embedFile("input.txt");
const Vec2 = @Vector(2, i32);

const SensorData = struct {
    sensor: Vec2,
    beacon: Vec2,
};

/// Advent of code - Day 15
///
/// Part 1 - Figure out the positions on a Y-Line that aren't overlapped by the sensor ranges
/// Part 2 - ???
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const result_1 = try countImpossibleBeaconPointsY(input_file[0..], 2000000);
    const result_2 = 0;

    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Count the points that aren't overlapped on the given Y by the senors
/// Sensors only detect the closest point but that gives us a range for which no other sensors can be in
///
/// Parse the X,Y of the sensor and the beacon
/// Find the manhattan distance between them
/// Spend the amount of moves to get to Y and use the remainder to find the x extents on Y for that sensor
/// This gives us a list of line segments covering the points that no beacons can be
///
fn countImpossibleBeaconPointsY(data: []const u8, comptime y: i32) !i32 {
    var line_segments: [40]Vec2 = undefined;
    var line_segment_count: u32 = 0;

    var line_it = std.mem.tokenize(u8, data, "\n");
    while (line_it.next()) |line| {
        const sensorData = try parseLine(line);

        const delta = sensorData.beacon - sensorData.sensor;
        const manhattan_dist = try std.math.absInt(delta[0]) + try std.math.absInt(delta[1]);
        const y_delta = try std.math.absInt(y - sensorData.sensor[1]);
        if (y_delta > manhattan_dist) {
            continue;
        }

        const x_range = manhattan_dist - y_delta;
        const x_min = sensorData.sensor[0] - x_range;
        const x_max = sensorData.sensor[0] + x_range;
        line_segments[line_segment_count] = Vec2{ x_min, x_max };
        line_segment_count += 1;
    }


    //Merge overlapping lines together - sorting first to so we merge from left to right
    std.sort.sort(Vec2, line_segments[0..line_segment_count], {}, sortByX);
    var total: i32 = 0;
    var i: usize = 0;
    while (i < line_segment_count) {
        var seg_a = &line_segments[i];
        var j = i + 1;
        while (j < line_segment_count) : (j += 1) {
            const seg_b = line_segments[j];
            if (seg_a.*[1] >= seg_b[0]) {
                seg_a.*[1] = std.math.max(seg_a.*[1], seg_b[1]);
            } else {
                break;
            }
        }

        //Add the new number of points covered by the line to the total
        total += seg_a.*[1] - seg_a.*[0];
        i = j;
    }

    return total;
}

/// Format: "Sensor at x=2, y=18: closest beacon is at x=-2, y=15"
/// Return the positions of the sensor and beacon
///
fn parseLine(line: []const u8) !SensorData {
    var i: u32 = 12;
    var j = i + 1;
    while (isDigit(line[j])) : (j += 1) {}
    const sensor_x = try std.fmt.parseInt(i32, line[i..j], 10);
    i = j + 1;

    while (isDigit(line[i]) == false) : (i += 1) {}
    j = i + 1;
    while (isDigit(line[j])) : (j += 1) {}
    const sensor_y = try std.fmt.parseInt(i32, line[i..j], 10);
    i = j + 1;

    while (isDigit(line[i]) == false) : (i += 1) {}
    j = i + 1;
    while (isDigit(line[j])) : (j += 1) {}
    const beacon_x = try std.fmt.parseInt(i32, line[i..j], 10);
    i = j + 1;

    while (isDigit(line[i]) == false) : (i += 1) {}
    const beacon_y = try std.fmt.parseInt(i32, line[i..], 10);

    return SensorData{ .sensor = Vec2{ sensor_x, sensor_y }, .beacon = Vec2{ beacon_x, beacon_y } };
}

/// Return true if it is an ASCII digit between 0-9
///
inline fn isDigit(c: u8) bool {
    return c == '-' or (c >= '0' and c <= '9');
}

/// Sort x small to large
///
fn sortByX(_: void, lhs: Vec2, rhs: Vec2) bool {
    return lhs[0] < rhs[0];
}
