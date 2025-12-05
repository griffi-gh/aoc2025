const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try std.fs.cwd().readFileAlloc(allocator, "input/day4", std.math.maxInt(usize));
    defer allocator.free(content);

    const width = std.mem.indexOfScalar(u8, content, '\n') orelse return error.NotFound;
    const height = try std.math.divCeil(usize, content.len, width + 1);

    std.log.debug("width: {d}, height: {d}", .{ width, height });

    var result: u32 = 0;

    var lines = std.mem.splitScalar(u8, content, '\n');
    var y: usize = 0;
    while (lines.next()) |line| {
        defer y += 1;
        outer: for (line, 0..) |chr, x| {
            if (chr != '@') continue;

            var neighbors: u32 = 0;
            const offs = [_]i32{ -1, 0, 1 };
            inline for (offs) |dy| {
                inline for (offs) |dx| {
                    const nx = @as(i32, @intCast(x)) + dx;
                    const ny = @as(i32, @intCast(y)) + dy;
                    if ((dx != 0 or dy != 0) and
                        (nx >= 0 and nx < width) and
                        (ny >= 0 and ny < height))
                    {
                        const idx: usize = @intCast(ny * (@as(i32, @intCast(width)) + 1) + nx);
                        neighbors += @intFromBool(content[idx] == '@');
                        if (neighbors >= 4) continue :outer;
                    }
                }
            }

            result += 1;
            std.debug.print("#{d} ({d}, {d}): {d}\n", .{ result, x, y, neighbors });
        }
    }

    std.log.info("result: {d}", .{result});
}
