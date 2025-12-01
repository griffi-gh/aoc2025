const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const day1 = b.addExecutable(.{
        .name = "day1",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/day1.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{},
        }),
    });
    b.installArtifact(day1);
}
