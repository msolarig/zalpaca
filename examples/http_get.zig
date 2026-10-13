const std = @import("std");

const Account = struct {
    status: []const u8,
    currency: []const u8,
    cash: []const u8,
    buying_power: []const u8,
    portfolio_value: []const u8,
};

pub fn main(init: std.process.Init) !void {
    const env = init.environ_map;

    const api_key = env.get("ALPACA_API_KEY") orelse
        return error.MissingApiKey;

    const secret_key = env.get("ALPACA_SECRET_KEY") orelse
        return error.MissingSecretKey;

    const status = try httpGet(init, api_key, secret_key);

    std.debug.print("HTTP status: {d}\n", .{@intFromEnum(status)});
}

pub fn httpGet(init: std.process.Init, api_key: []const u8, secret_key: []const u8) !std.http.Status {
    const gpa = init.gpa;
    const io = init.io;

    var http_client: std.http.Client = .{ .allocator = gpa, .io = io };
    defer http_client.deinit();

    const headers = [_]std.http.Header{
        .{
            .name = "APCA-API-KEY-ID",
            .value = api_key,
        },
        .{
            .name = "APCA-API-SECRET-KEY",
            .value = secret_key,
        },
    };

    var request = try http_client.request(.GET, .{
        .scheme = "https",
        .host = .{ .percent_encoded = "paper-api.alpaca.markets" },
        .port = 443,
        .path = .{ .percent_encoded = "/v2/account" },
    }, .{
        .extra_headers = &headers,
        .redirect_behavior = .unhandled, // for privacy & safety - until privileged headers is resolved
        // STD appears to not write privileged headers into the final request, forcing to use extra_headers.
        // revisit after next Zig update. (potential bug report)
    });
    defer request.deinit();

    try request.sendBodiless();

    var redirect_buffer: [1024]u8 = undefined;
    var response = try request.receiveHead(&redirect_buffer);

    const body = try response.reader(&.{}).allocRemaining(
        gpa,
        .limited(1024 * 1024),
    );
    defer gpa.free(body);

    const parsed = try std.json.parseFromSlice(
        Account,
        gpa,
        body,
        .{ .ignore_unknown_fields = true },
    );
    defer parsed.deinit();

    const account = parsed.value;
    std.debug.print("cash {s} {s}\n", .{
        account.cash,
        account.currency,
    });

    return response.head.status;
}
