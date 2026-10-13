const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const mod = b.addModule("zalpaca", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/unit/root.zig"),
            .target = target,
            .optimize = .Debug,
            .imports = &.{
                .{ .name = "zalpaca", .module = mod },
            },
        }),
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_unit_step = b.step("test-unit", "Run unit tests");
    test_unit_step.dependOn(&run_unit_tests.step);

    const integration_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/integration/root.zig"),
            .target = target,
            .optimize = .Debug,
            .imports = &.{
                .{ .name = "zalpaca", .module = mod },
            },
        }),
    });

    const run_integration_tests = b.addRunArtifact(integration_tests);

    const test_integration_step = b.step(
        "test-integration",
        "Run integration tests (requires credentials and network)",
    );
    test_integration_step.dependOn(&run_integration_tests.step);

    // Default offline test suite
    const test_step = b.step("test", "Run all offline tests");
    test_step.dependOn(&run_unit_tests.step);

    const check_step = b.step("check", "Check test compilation");
    check_step.dependOn(&unit_tests.step);
    check_step.dependOn(&integration_tests.step);
}
