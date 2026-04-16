const std = @import("std");
const builtin = @import("builtin");
const locale = @import("locale.zig");
const messages = @import("messages.zig");

extern "kernel32" fn SetConsoleOutputCP(wCodePageID: std.os.windows.UINT) callconv(.winapi) std.os.windows.BOOL;

/// A simple joke utility that does only one thing — after launching,
/// it outputs the phrase "I love you!" to the console.
///
/// If you pass a parameter with a name, the phrase will include that name.
/// For example: "I love you, Jane!".
pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    // Get the System Locale or default to en_US
    const lang = locale.getLocale(init) catch |err| switch (err) {
        error.OutOfMemory => return err,
        else => try init.gpa.dupe(u8, "en_US"),
    };
    defer init.gpa.free(lang);

    // Get the Message by the System Locale
    const message = messages.getMessageByLocale(lang);

    // Get the arguments
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    if (builtin.os.tag == .windows) {
        const CP_UTF8 = 65001;
        _ = SetConsoleOutputCP(CP_UTF8);
    }

    if (args.len > 1) {
        try stdout.print("{s}, {s}!\n", .{ message, args[1] });
    } else {
        try stdout.print("{s}!\n", .{message});
    }

    try stdout.flush();
}
