const std = @import("std");

// this is currently borked in some way
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

    var unique: std.hash_map.AutoHashMap(u64, void) = .init(allocator);
    defer unique.deinit();

    var ranges = std.mem.splitScalar(u8, content, ',');
    while (ranges.next()) |range| {
        unique.clearRetainingCapacity();

        var split = std.mem.splitScalar(u8, range, '-');
        const rstart = split.next() orelse return error.InvalidInput;
        const rend = split.rest();
        std.log.info("=== range: {s}-{s} ===", .{ rstart, rend });

        const rstart_int = std.fmt.parseInt(u64, rstart, 10) catch return error.InvalidInput;
        const rend_int = std.fmt.parseInt(u64, rend, 10) catch return error.InvalidInput;

        for (1..(rend.len >> 1) + 1) |chunk_size| {
            std.log.info("chunk_size: {}", .{chunk_size});

            const rstart_degenerate = (rstart.len % chunk_size) != 0;
            const rend_degenerate = (rend.len % chunk_size) != 0;

            if (rstart_degenerate and rend_degenerate) {
                std.log.debug("- skipping: both start and end degenerate", .{});
                continue;
            }

            const rhalf_start = blk: {
                if (rstart_degenerate) {
                    break :blk try std.math.powi(u64, 10, @intCast(chunk_size - 1));
                } else {
                    break :blk std.fmt.parseInt(u64, rstart[0..chunk_size], 10) catch return error.InvalidInput;
                }
            };
            const rhalf_end = blk: {
                if (rend_degenerate) {
                    break :blk try std.math.powi(u64, 10, @intCast(chunk_size)) - 1;
                } else {
                    break :blk std.fmt.parseInt(u64, rend[0..chunk_size], 10) catch return error.InvalidInput;
                }
            };

            const rhalf_check_start = @min(rhalf_start, rhalf_end);
            const rhalf_check_end = @max(rhalf_start, rhalf_end);

            std.log.debug("check rhalf range: {d},{d} => {d}-{d}", .{
                rhalf_start,
                rhalf_end,
                rhalf_check_start,
                rhalf_check_end,
            });

            for (rhalf_check_start..rhalf_check_end + 1) |half| {
                var full: u64 = 0;

                const shift = try std.math.powi(u64, 10, chunk_size);

                var repeat_cnt = (rstart.len / chunk_size);

                for (0..repeat_cnt) |_| {
                    full = full * shift + half;
                }
                std.log.debug("{d} ({d} {d})", .{ full, shift, repeat_cnt });
                if (repeat_cnt >= 2 and !rstart_degenerate) {
                    if (full > rend_int) continue;
                    if (rstart_int <= full and !unique.contains(full)) {
                        std.log.info("invalid: {d}", .{full});
                        result += full;
                        try unique.put(full, {});
                        continue;
                    }
                }

                const adt_iter = (rend.len / chunk_size) - repeat_cnt;
                if (adt_iter == 0 or rend_degenerate) continue;

                repeat_cnt += adt_iter;
                for (0..adt_iter) |_| {
                    full = full * shift + half;
                }
                std.log.debug("{d} ({d} {d})", .{ full, shift, repeat_cnt });
                if (repeat_cnt >= 2) {
                    // std.log.debug("{d}", .{full});
                    if (full >= rstart_int and full <= rend_int) {
                        std.log.info("invalid: {d}", .{full});
                        if (!unique.contains(full)) result += full;
                        try unique.put(full, {});
                        continue;
                    }
                }
            }
        }
    }

    std.log.debug("result: {d}", .{result});
}
