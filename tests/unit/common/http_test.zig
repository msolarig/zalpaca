const std = @import("std");
const Transport = @import("zalpaca").Transport;

test "Transport initializes and deinitializes" {
    var transport = Transport.init(
        std.testing.allocator,
        std.testing.io,
    );
    defer transport.deinit();

    try std.testing.expectEqual(std.testing.allocator, transport.alloc);
}
