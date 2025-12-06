const std = @import("std");

const Range = struct {
    start: u64,
    end: u64,

    fn overlaps(self: *const Range, other: *const Range) bool {
        return self.start <= other.end and self.end >= other.start;
    }

    fn compare(_: void, a: Range, b: Range) bool {
        return a.start < b.start;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var ranges: std.ArrayList(Range) = .empty;
    defer ranges.deinit(allocator);

    // read ranges from input file
    const buffer = try std.fs.cwd().readFileAlloc(allocator, "input/day5", std.math.maxInt(usize));
    defer allocator.free(buffer);

    var sections_iter = std.mem.splitSequence(u8, buffer, "\n\n");
    var ranges_iter = std.mem.tokenizeScalar(u8, sections_iter.first(), '\n');
    while (ranges_iter.next()) |range_str| {
        var range_iter = std.mem.splitScalar(u8, range_str, '-');
        try ranges.append(allocator, Range{
            .start = try std.fmt.parseInt(u64, range_iter.first(), 10),
            .end = try std.fmt.parseInt(u64, range_iter.rest(), 10),
        });
    }
    if (ranges.items.len == 0) @panic("ranges are empty");

    // sort and merge consecutive ranges
    std.mem.sortUnstable(Range, ranges.items, {}, Range.compare);

    var cur_range_idx: usize = 0;
    for (ranges.items[1..]) |*range| {
        const cur_range = &ranges.items[cur_range_idx];
        if (range.overlaps(cur_range)) {
            cur_range.start = @min(cur_range.start, range.start);
            cur_range.end = @max(cur_range.end, range.end);
        } else {
            cur_range_idx += 1;
            ranges.items[cur_range_idx] = range.*;
        }
    }
    ranges.shrinkRetainingCapacity(cur_range_idx + 1);

    // compute result
    var result: u64 = 0;
    for (ranges.items) |range| {
        std.log.debug("{d}-{d}", .{ range.start, range.end });
        result += range.end - range.start + 1;
    }

    std.log.info("result: {d}", .{result});
}
