const std = @import("std");

pub fn build(b: *std.Build) void {
    const module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
        .link_libc = true,
    });
    const exe = b.addExecutable(.{ .name = "triangulos", .root_module = module });
    b.installArtifact(exe);
    const run = b.addRunArtifact(exe);
    b.step("run", "Genera las tres imagenes").dependOn(&run.step);
    const tests = b.addTest(.{ .root_module = module });
    const run_tests = b.addRunArtifact(tests);
    b.step("test", "Revisa los calculos y los colores").dependOn(&run_tests.step);
}
