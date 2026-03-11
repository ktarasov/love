const std = @import("std");

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

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len > 1) {
        try stdout.print("I love you, {s}!\n", .{args[1]});
    } else {
        try stdout.print("I love you!\n", .{});
    }

    try stdout.flush();
}
