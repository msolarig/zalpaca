const std = @import("std");

pub const Transport = struct {
    alloc: std.mem.Allocator,
    http_client: std.http.Client,

    pub fn init(alloc: std.mem.Allocator, io: std.Io) Transport {
        const transport = Transport{
            .alloc = alloc,
            .http_client = .{ .allocator = alloc, .io = io },
        };

        return transport;
    }

    pub fn get(self: *Transport, uri: std.Uri, headers: []const std.http.Header) !Response {
        var request = try self.http_client.request(.GET, uri, .{
            .extra_headers = headers,
            .redirect_behavior = .unhandled, // for privacy & security until privileged_heads gets patched
        });
        defer request.deinit();

        try request.sendBodiless();

        var buffer: [1024]u8 = undefined;
        var raw_response = try request.receiveHead(&buffer);

        const body = try raw_response.reader(&.{}).allocRemaining(
            self.alloc,
            .limited(1024 * 1024),
        );

        const response = Response{
            .alloc = self.alloc,
            .status = raw_response.head.status,
            .body = body,
        };

        return response;
    }

    pub fn deinit(self: *Transport) void {
        self.http_client.deinit();
    }
};

pub const Response = struct {
    alloc: std.mem.Allocator,
    status: std.http.Status,
    body: []u8,

    pub fn deinit(self: *Response) void {
        self.alloc.free(self.body);
    }
};
