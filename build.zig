const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const modules = .{
        "day1_2",
        "day2_1",
        "day2_2",
        "day3_1",
        "day3_2",
        "day4_1",
        "day4_2",
    };

    const check = b.step("check", "check all");

    inline for (modules) |name| {
        var buffer: [64]u8 = undefined;
        const src = try std.fmt.bufPrint(&buffer, "src/{s}.zig", .{name});

        const mod = b.createModule(.{
            .root_source_file = b.path(src),
            .target = target,
            .optimize = optimize,
            .imports = &.{},
        });

        const exe = b.addExecutable(.{
            .name = name,
            .root_module = mod,
        });
        b.installArtifact(exe);

        const exe_check = b.addExecutable(.{
            .name = name,
            .root_module = mod,
        });
        check.dependOn(&exe_check.step);

        const build_step = b.step("build-" ++ name, "Build " ++ name);
        build_step.dependOn(&exe.step);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(build_step);

        const run_step = b.step("run-" ++ name, "Run " ++ name);
        run_step.dependOn(&run_cmd.step);
    }
}
