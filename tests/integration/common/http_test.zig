const std = @import("std");
const Transport = @import("zalpaca").Transport;

test "Transport authenticated GET request" {
    var transport = Transport.init(
        std.testing.allocator,
        std.testing.io,
    );
    defer transport.deinit();

    var env = try std.testing.environ.createMap(std.testing.allocator);
    defer env.deinit();

    const api_key = env.get("APCA_API_KEY_ID") orelse
        return error.MissingApiKey;
    const secret_key = env.get("APCA_API_SECRET_KEY") orelse
        return error.MissingSecretKey;

    const headers = [_]std.http.Header{
        .{ .name = "APCA-API-KEY-ID", .value = api_key },
        .{ .name = "APCA-API-SECRET-KEY", .value = secret_key },
    };

    const uri = try std.Uri.parse("https://paper-api.alpaca.markets/v2/account");

    var response = try transport.get(uri, &headers);
    defer response.deinit();

    try std.testing.expectEqual(std.http.Status.ok, response.status);
    try std.testing.expect(response.body.len > 0);

    const parsed = try std.json.parseFromSlice(
        std.json.Value,
        std.testing.allocator,
        response.body,
        .{},
    );
    defer parsed.deinit();

    try std.testing.expect(parsed.value == .object);
}
