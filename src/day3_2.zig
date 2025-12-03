const std = @import("std");

const joltage_len = 12;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try std.fs.cwd().readFileAlloc(allocator, "input/day3", std.math.maxInt(usize));
    defer allocator.free(content);

    var result: u64 = 0;

    var lines = std.mem.splitScalar(u8, content, '\n');
    while (lines.next()) |line| {
        var joltage: u64 = 0;
        var head: usize = 0;
        for (0..joltage_len) |i| {
            const headroom = joltage_len - i - 1;
            head += std.mem.indexOfMax(u8, line[head..(line.len - headroom)]);
            joltage = joltage * 10 + (line[head] - '0');
            head += 1;
        }
        std.log.debug("{d}", .{joltage});
        result += joltage;
    }

    std.log.info("result: {d}", .{result});
}
