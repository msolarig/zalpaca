const std = @import("std");
const Config = @import("zalpaca").Config;

test "config: default values" {
    const config = Config{
        .api_key = "test_api_key",
        .secret_key = "test_secret_key",
    };

    try std.testing.expect(config.paper);
    try std.testing.expect(config.url_override == null);
}

test "config: custom values" {
    const config = Config{
        .api_key = "test_api_key",
        .secret_key = "test_secret_key",
        .paper = false,
        .url_override = "https://example.com",
    };

    try std.testing.expect(!config.paper);
    try std.testing.expectEqualStrings("https://example.com", config.url_override.?);
}
