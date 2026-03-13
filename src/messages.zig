const std = @import("std");

const MessagesEntity = struct {
    key: []const u8,
    value: []const u8,
};

const Strings = [_]MessagesEntity{
    .{ .key = "en_US", .value = "I love you" },
    .{ .key = "ru_RU", .value = "Я люблю тебя" },
};

pub fn getMessageByLocale(locale: []const u8) []const u8 {
    inline for (Strings) |string| {
        if (std.mem.eql(u8, locale, string.key)) {
            return string.value;
        }
    }

    return Strings[0].value;
}

test "Correct cases" {
    try std.testing.expectEqualStrings("I love you", getMessageByLocale("en_US"));
    try std.testing.expectEqualStrings("Я люблю тебя", getMessageByLocale("ru_RU"));
    try std.testing.expectEqualStrings("I love you", getMessageByLocale("te_ST"));
}
