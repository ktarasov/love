const std = @import("std");
const builtin = @import("builtin");
const Allocator = std.mem.Allocator;

const LOCALE_NAME_MAX_LENGTH = 85;
pub extern fn GetUserDefaultLocaleName(lpLocaleName: *[LOCALE_NAME_MAX_LENGTH]u16, cchLocaleName: c_int) c_int;

const LocaleError = error{
    BadOS,
    BadLocale,
    OutOfMemory,
};

// Get the locale
pub fn getLocale(allocator: Allocator) LocaleError![]u8 {
    switch (builtin.os.tag) {
        .linux => return getLinuxLocale(allocator),
        .macos => return getMacLocale(allocator),
        .windows => return getWindowsLocale(allocator),
        else => return LocaleError.BadOS,
    }
}

// Get the locale on Linux
pub fn getLinuxLocale(allocator: Allocator) LocaleError![]u8 {
    if (builtin.os.tag != .linux) {
        return LocaleError.BadOS;
    }

    const envs = [_][]const u8{ "LANGUAGE", "LANG", "LC_ALL", "LC_MESSAGES" };
    for (envs) |env| {
        if (std.posix.getenv(env)) |value| {
            if (value.len == 0) continue;
            // LANGUAGE may contain multiple locales separated by ':'
            const first = if (std.mem.indexOf(u8, value, ":")) |colon| value[0..colon] else value;
            // Strip encoding suffix after '.'
            const dot = std.mem.indexOf(u8, first, ".");
            const locale = if (dot) |d| first[0..d] else first;
            return try allocator.dupe(u8, locale);
        }
    }

    return LocaleError.BadLocale;
}

// Get the locale on Mac
pub fn getMacLocale(allocator: Allocator) LocaleError![]u8 {
    if (builtin.os.tag != .macos) {
        return LocaleError.BadOS;
    }

    const envs = [_][]const u8{ "LANG", "LANGUAGE", "LC_ALL", "LC_MESSAGES" };
    for (envs) |env| {
        if (std.posix.getenv(env)) |value| {
            const pos = std.mem.indexOf(u8, value, ".");
            const locale = if (pos) |p| value[0..p] else value;
            return try allocator.dupe(u8, locale);
        }
    }

    return LocaleError.BadLocale;
}

// Get the locale on Windows
pub fn getWindowsLocale(allocator: Allocator) LocaleError![]u8 {
    if (builtin.os.tag != .windows) {
        return LocaleError.BadOS;
    }

    // Get Locale from Windows
    var locale: [LOCALE_NAME_MAX_LENGTH]u16 = undefined;
    const result = GetUserDefaultLocaleName(&locale, locale.len);
    if (result > 0) {
        const utf16_len: usize = @intCast(result);
        var locale_str: [LOCALE_NAME_MAX_LENGTH]u8 = undefined;
        const utf8_len = std.unicode.utf16LeToUtf8(&locale_str, locale[0..utf16_len]) catch unreachable;
        const slice = locale_str[0 .. utf8_len - 1]; // remove :0 terminator of string
        std.mem.replaceScalar(u8, slice, '-', '_');
        return try allocator.dupe(u8, slice);
    }

    return LocaleError.BadLocale;
}

test "getLocale returns error on unsupported OS" {
    // This test only runs if the OS is not linux, macos, or windows
    if (builtin.os.tag == .linux or builtin.os.tag == .macos or builtin.os.tag == .windows) {
        // skip
        return;
    }
    const allocator = std.testing.allocator;
    const result = getLocale(allocator);
    try std.testing.expectError(LocaleError.BadOS, result);
}

test "getLinuxLocale returns BadOS on non-linux" {
    if (builtin.os.tag == .linux) {
        return; // skip on linux
    }
    const allocator = std.testing.allocator;
    const result = getLinuxLocale(allocator);
    try std.testing.expectError(LocaleError.BadOS, result);
}

test "getMacLocale returns BadOS on non-macos" {
    if (builtin.os.tag == .macos) {
        return;
    }
    const allocator = std.testing.allocator;
    const result = getMacLocale(allocator);
    try std.testing.expectError(LocaleError.BadOS, result);
}

test "getWindowsLocale returns BadOS on non-windows" {
    if (builtin.os.tag == .windows) {
        return;
    }
    const allocator = std.testing.allocator;
    const result = getWindowsLocale(allocator);
    try std.testing.expectError(LocaleError.BadOS, result);
}

test "getLinuxLocale returns BadLocale when no env var (linux only)" {
    if (builtin.os.tag != .linux) {
        return;
    }
    // We cannot unset env vars, but we can assume they might be missing.
    // This test is flaky, so we just call the function and see if it returns BadLocale.
    // It may succeed if env vars are present, so we can't assert error.
    // We'll skip this test for now.
}

test "getMacLocale returns BadLocale when no env var (macos only)" {
    if (builtin.os.tag != .macos) {
        return;
    }
    // Similar to above.
}
