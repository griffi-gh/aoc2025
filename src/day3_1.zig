const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try std.fs.cwd().readFileAlloc(allocator, "input/day3", std.math.maxInt(usize));
    defer allocator.free(content);

    var result: u64 = 0;

    var lines = std.mem.splitScalar(u8, content, '\n');
    while (lines.next()) |line| {
        const maxIdx = std.mem.indexOfMax(u8, line[0..(line.len - 1)]);
        const max0 = line[maxIdx];
        const max1 = std.mem.max(u8, line[maxIdx + 1 ..]);
        result += 10 * (max0 - '0') + (max1 - '0');
    }

    std.log.info("result: {d}", .{result});
}
