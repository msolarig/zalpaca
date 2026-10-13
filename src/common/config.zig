pub const Config = struct {
    api_key: []const u8,
    secret_key: []const u8,
    paper: bool = true,
    url_override: ?[]const u8 = null, // Not implemented
};
