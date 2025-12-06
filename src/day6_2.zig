const std = @import("std");

// TODO finish this

const Operation = struct {
    operator: u8 = 0,
    values: std.ArrayList(i64) = .empty,

    pub fn perform(self: *const Operation) i64 {
        var sum: i64 = self.values.items[0];
        for (self.values.items[1..]) |value| {
            switch (self.operator) {
                '+' => sum += value,
                '*' => sum *= value,
                else => unreachable,
            }
        }
        return sum;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const buffer = try std.fs.cwd().readFileAlloc(allocator, "input/day6", std.math.maxInt(usize));
    defer allocator.free(buffer);

    var operations: std.ArrayList(Operation) = .empty;
    defer {
        for (operations.items) |*operation| operation.values.deinit(allocator);
        operations.deinit(allocator);
    }

    // var line_iter = std.mem.splitScalar(u8, buffer, '\n');
    // const width = line_iter.first().len();
    // const height = try std.math.divCeil(usize, buffer, width +1);

    // _ = width; // autofix

    // var line_iter = std.mem.tokenizeScalar(u8, buffer, '\n');
    // while (line_iter.next()) |line| {
    //     var tok_iter = std.mem.tokenizeScalar(u8, line, ' ');
    //     var idx: usize = 0;
    //     while (tok_iter.next()) |token| {
    //         defer idx += 1;

    //         if (idx >= operations.items.len) try operations.append(allocator, Operation{});
    //         const operation = &operations.items[idx];

    //         switch (token[0]) {
    //             '0'...'9' => {
    //                 if (operation.values.items.len < token.len) {
    //                     try operation.values.appendNTimes(allocator, 0, token.len - operation.values.items.len);
    //                 }
    //                 for (token, 0..) |digit_char, digit_idx| {
    //                     const digit = digit_char - '0';
    //                     const op_value = &operation.values.items[digit_idx];
    //                     op_value.* = (op_value.* * 10) + digit;
    //                 }
    //                 // if (operation.values)
    //             },
    //             '+', '*' => {
    //                 operation.operator = token[0];
    //             },
    //             else => {},
    //         }
    //     }
    // }

    var sum: i64 = 0;
    for (operations.items) |operation| {
        const result = operation.perform();
        std.log.debug(
            "{s} {any}: {d}",
            .{ [_]u8{operation.operator}, operation.values.items, result },
        );
        sum += result;
    }

    std.log.info("result: {d}", .{sum});
}
