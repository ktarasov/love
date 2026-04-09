const std = @import("std");
const TargetQuery = std.Target.Query;

const release_targets = [_]TargetQuery{
    .{
        .cpu_arch = .x86_64,
        .os_tag = .linux,
    },
    .{
        .cpu_arch = .x86_64,
        .os_tag = .windows,
    },
    .{
        .cpu_arch = .x86_64,
        .os_tag = .macos,
    },
    .{
        .cpu_arch = .aarch64,
        .os_tag = .macos,
    },
};

const FileExtension = enum {
    zip,
    @"tar.xz",
    @"tar.gz",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "love",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{},
        }),
    });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);

    { // zig build release
        const release_step = b.step("release", "Build release binaries");
        for (release_targets) |release_target| {
            const resolved_target = b.resolveTargetQuery(release_target);
            const exe_release = b.addExecutable(.{
                .name = "love",
                .root_module = b.createModule(.{
                    .root_source_file = b.path("src/main.zig"),
                    .target = resolved_target,
                    .optimize = .ReleaseSmall,
                    .imports = &.{},
                }),
            });

            const dir_name = b.fmt("{t}-{t}", .{
                resolved_target.result.cpu.arch,
                resolved_target.result.os.tag,
            });
            const install_dir = std.Build.InstallDir{ .custom = dir_name };
            const release_cmd = b.addInstallArtifact(exe_release, .{ .dest_dir = .{ .override = install_dir } });
            release_step.dependOn(&release_cmd.step);
        }
    }
}
