const std = @import("std");
const Client = @import("zalpaca").Client;

test "Client: paper trading client" {
    var client = try Client.init(std.testing.allocator, std.testing.io, .{
        .api_key = "test_api_key",
        .secret_key = "test_secret_key",
    });
    defer client.deinit();

    try std.testing.expect(client.paper);
    try std.testing.expectEqualStrings("test_api_key", client.api_key);
    try std.testing.expectEqualStrings("test_secret_key", client.secret_key);
    try std.testing.expectEqualStrings("https://paper-api.alpaca.markets", client.endpoint);
}

test "Client: live trading client" {
    var client = try Client.init(std.testing.allocator, std.testing.io, .{
        .api_key = "test_api_key",
        .secret_key = "test_secret_key",
        .paper = false,
    });
    defer client.deinit();

    try std.testing.expect(!client.paper);
    try std.testing.expectEqualStrings("test_api_key", client.api_key);
    try std.testing.expectEqualStrings("test_secret_key", client.secret_key);
    try std.testing.expectEqualStrings("https://api.alpaca.markets", client.endpoint);
}

//
// IMPORTANT: Missing memory ownership and allocation failure testing!!!
//
