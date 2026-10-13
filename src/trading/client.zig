const std = @import("std");
const Config = @import("../common/config.zig").Config;
const Transport = @import("../common/http.zig").Transport;

pub const Client = struct {
    alloc: std.mem.Allocator,
    api_key: []u8,
    secret_key: []u8,
    paper: bool,
    endpoint: []const u8,
    transport: Transport,

    pub fn init(alloc: std.mem.Allocator, io: std.Io, config: Config) !Client {
        const api_key = try alloc.dupe(u8, config.api_key);
        errdefer alloc.free(api_key);

        const secret_key = try alloc.dupe(u8, config.secret_key);
        errdefer alloc.free(secret_key);

        const transport = Transport.init(alloc, io);

        const client = Client{
            .alloc = alloc,
            .api_key = api_key,
            .secret_key = secret_key,
            .paper = config.paper,
            .endpoint = if (config.paper)
                "https://paper-api.alpaca.markets"
            else
                "https://api.alpaca.markets",
            .transport = transport,
        };

        return client;
    }

    pub fn deinit(self: *Client) void {
        self.transport.deinit();
        self.alloc.free(self.api_key);
        self.alloc.free(self.secret_key);
    }
};
