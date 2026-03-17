const std = @import("std");
const builtin = @import("builtin");
const locale = @import("locale.zig");
const messages = @import("messages.zig");

const CP_UTF8 = 65001;

/// A simple joke utility that does only one thing — after launching,
/// it outputs the phrase "I love you!" to the console.
///
/// If you pass a parameter with a name, the phrase will include that name.
/// For example: "I love you, Jane!".
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    // Get the System Locale or default to en_US
    const lang = locale.getLocale(allocator) catch |err| switch (err) {
        error.OutOfMemory => return err,
        else => try allocator.dupe(u8, "en_US"),
    };
    defer allocator.free(lang);

    // Get the Message by the System Locale
    const message = messages.getMessageByLocale(lang);

    // Get the arguments
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (builtin.os.tag == .windows) {
        _ = std.os.windows.kernel32.SetConsoleOutputCP(CP_UTF8);
    }

    if (args.len > 1) {
        try stdout.print("{s}, {s}!\n", .{ message, args[1] });
    } else {
        try stdout.print("{s}!\n", .{message});
    }

    try stdout.flush();
}
