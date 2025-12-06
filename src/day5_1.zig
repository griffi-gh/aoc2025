const std = @import("std");

const Range = struct {
    start: u64,
    end: u64,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const buffer = try std.fs.cwd().readFileAlloc(allocator, "input/day5", std.math.maxInt(usize));
    defer allocator.free(buffer);

    var sections_iter = std.mem.splitSequence(u8, buffer, "\n\n");

    var ranges: std.ArrayList(Range) = .empty;
    defer ranges.deinit(allocator);

    var ranges_iter = std.mem.splitScalar(u8, sections_iter.first(), '\n');
    while (ranges_iter.next()) |range| {
        var range_iter = std.mem.splitScalar(u8, range, '-');
        const start = try std.fmt.parseInt(u64, range_iter.first(), 10);
        const end = try std.fmt.parseInt(u64, range_iter.rest(), 10);
        try ranges.append(allocator, Range{ .start = start, .end = end });
    }

    var result: u32 = 0;

    var products_iter = std.mem.splitScalar(u8, sections_iter.rest(), '\n');
    while (products_iter.next()) |product| {
        const product_int = try std.fmt.parseInt(u64, product, 10);
        for (ranges.items) |*range| {
            if (product_int >= range.start and product_int <= range.end) {
                std.log.debug("product {d} is fresh", .{product_int});
                result += 1;
                break;
            }
        }
    }

    std.log.info("result: {d}", .{result});
}
