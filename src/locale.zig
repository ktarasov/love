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

    const locale = std.posix.getenv("LANGUAGE") orelse return LocaleError.BadLocale;
    const locale_str = locale[0..locale.len];

    return try allocator.dupe(u8, locale_str);
}

// Get the locale on Mac
pub fn getMacLocale(allocator: Allocator) LocaleError![]u8 {
    if (builtin.os.tag != .macos) {
        return LocaleError.BadOS;
    }

    const locale = std.posix.getenv("LANG") orelse return LocaleError.BadLocale;
    const pos = std.mem.indexOf(u8, locale, ".");
    if (pos) |p| {
        return try allocator.dupe(u8, locale[0..p]);
    }

    return LocaleError.BadLocale; // TODO: Implement (not needed for now)
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
        const slice = locale_str[0..utf8_len];
        std.mem.replaceScalar(u8, slice, '-', '_');
        return try allocator.dupe(u8, slice);
    }

    return LocaleError.BadLocale;
}
