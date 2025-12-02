const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try std.fs.cwd().readFileAlloc(
        allocator,
        "input/day2",
        std.math.maxInt(usize),
    );
    defer allocator.free(content);

    var result: u64 = 0;

    var ranges = std.mem.splitScalar(u8, content, ',');
    while (ranges.next()) |range| {
        var split = std.mem.splitScalar(u8, range, '-');
        const rstart = split.next() orelse return error.InvalidInput;
        const rend = split.rest();
        std.log.info("=== range: {s}-{s} ===", .{ rstart, rend });

        const rstart_degenerate = (rstart.len & 1) != 0;
        const rend_degenerate = (rend.len & 1) != 0;

        if (rstart_degenerate and rend_degenerate) {
            std.log.debug("- skipping: both start and end degenerate", .{});
            continue;
        }

        const start_inth_len = (rstart.len + (rstart.len & 1)) >> 1;
        const end_inth_len = rend.len >> 1;

        if (start_inth_len > end_inth_len) {
            std.log.debug("- skipping: start_inth_len > rend_inth_len", .{});
            continue;
        }

        const rhalf_start = blk: {
            if (rstart_degenerate) {
                break :blk try std.math.powi(u64, 10, @intCast(start_inth_len - 1));
            } else {
                break :blk std.fmt.parseInt(u64, rstart[0..start_inth_len], 10) catch return error.InvalidInput;
            }
        };
        const rhalf_end = blk: {
            if (rend_degenerate) {
                break :blk try std.math.powi(u64, 10, @intCast(end_inth_len)) - 1;
            } else {
                break :blk std.fmt.parseInt(u64, rend[0..end_inth_len], 10) catch return error.InvalidInput;
            }
        };

        std.log.debug("check rhalf range: {d}-{d}", .{ rhalf_start, rhalf_end });

        if (rhalf_start > rhalf_end) {
            std.log.debug("- skipping: rhalf_start > rhalf_end", .{});
            continue;
        }

        const rstart_int = std.fmt.parseInt(u64, rstart, 10) catch return error.InvalidInput;
        const rend_int = std.fmt.parseInt(u64, rend, 10) catch return error.InvalidInput;

        for (rhalf_start..rhalf_end + 1) |half| {
            const full = half * (try std.math.powi(u64, 10, std.math.log10(half) + 1) + 1);
            if (full < rstart_int) continue;
            if (full > rend_int) break;
            std.log.info("invalid: {d}", .{full});
            result += full;
        }
    }

    std.log.debug("result: {d}", .{result});
}
