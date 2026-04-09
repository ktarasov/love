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
        var compressed_artifacts: std.StringArrayHashMapUnmanaged(std.Build.LazyPath) = .empty;
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

            const is_windows = release_target.os_tag == .windows;
            const exe_name = b.fmt("{s}{s}", .{ exe.name, resolved_target.result.exeFileExt() });

            const install_dir: std.Build.InstallDir = .{ .custom = "compressed" };
            const extensions: []const FileExtension = if (is_windows) &.{.zip} else &.{.@"tar.gz"};
            for (extensions) |extension| {
                const file_name = b.fmt("love-{t}-{t}.{t}", .{
                    resolved_target.result.cpu.arch,
                    resolved_target.result.os.tag,
                    extension,
                });

                const compress_cmd = std.Build.Step.Run.create(b, "compress artifact");
                compress_cmd.clearEnvironment();
                compress_cmd.step.max_rss = 16 * 1024 * 1024; // 16 MiB

                switch (extension) {
                    .zip => {
                        compress_cmd.addArgs(&.{ "7z", "a", "-mx=9" });
                        compressed_artifacts.putNoClobber(b.allocator, file_name, compress_cmd.addOutputFileArg(file_name)) catch @panic("OOM");
                        compress_cmd.addArtifactArg(exe_release);
                    },
                    .@"tar.gz",
                    => {
                        compress_cmd.addArgs(&.{ "tar", "caf" });
                        compressed_artifacts.putNoClobber(b.allocator, file_name, compress_cmd.addOutputFileArg(file_name)) catch @panic("OOM");
                        compress_cmd.addPrefixedDirectoryArg("-C", exe_release.getEmittedBinDirectory());
                        compress_cmd.addArg(exe_name);
                        compress_cmd.addArgs(&.{
                            "--sort=name",
                            "--numeric-owner",
                            "--owner=0",
                            "--group=0",
                            "--mtime=1970-01-01",
                        });
                    },
                }
            }

            const install_dir: std.Build.InstallDir = .{ .custom = "compressed" };
            for (compressed_artifacts.keys(), compressed_artifacts.values()) |file_name, file_path| {
                const install_tarball = b.addInstallFileWithDir(file_path, install_dir, file_name);
                release_step.dependOn(&install_tarball.step);
            }
        }
    }
}
