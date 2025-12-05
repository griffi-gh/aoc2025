const std = @import("std");

const Dial = struct {
    dial: i32 = 50,
    clicks: i32 = 0,

    fn iteration(self: *Dial, rotation: i32) void {
        const abs_rotation: i32 = @intCast(@abs(rotation));
        const distance = if (rotation < 0) 100 - self.dial else self.dial;
        self.clicks += @max(0, @divTrunc(distance + abs_rotation, 100) -
            @intFromBool(self.dial == 0 and rotation < 0));
        self.dial = @mod(self.dial + 1, 100);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try std.fs.cwd().readFileAlloc(
        allocator,
        "input/day1",
        std.math.maxInt(usize),
    );
    defer allocator.free(content);

    var dial = Dial{};

    var lines = std.mem.splitScalar(u8, content, '\n');
    while (lines.next()) |line| {
        const sign: i32 = if (line[0] == 'L') -1 else 1;
        const rotation: i32 = try std.fmt.parseInt(i32, line[1..], 10);
        dial.iteration(sign * rotation);
    }

    std.log.info("clicks: {d}", .{dial.clicks});
}
