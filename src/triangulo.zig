const std = @import("std");

pub const Punto = struct { x: f64, y: f64 };

fn areaDoble(a: Punto, b: Punto, c: Punto) f64 {
    return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
}

pub fn coordenadas(a: Punto, b: Punto, c: Punto, p: Punto) ?[3]f64 {
    const total = areaDoble(a, b, c);
    if (total == 0) return null;
    return .{
        areaDoble(p, b, c) / total,
        areaDoble(a, p, c) / total,
        areaDoble(a, b, p) / total,
    };
}

pub fn color(a: Punto, b: Punto, c: Punto, p: Punto) ?[3]u8 {
    const pesos = coordenadas(a, b, c, p) orelse return null;
    for (pesos) |peso| {
        if (peso < -1e-10) return null;
    }
    var rgb: [3]u8 = undefined;
    for (pesos, 0..) |peso, i| {
        rgb[i] = @intFromFloat(@round(std.math.clamp(peso, 0, 1) * 255));
    }
    return rgb;
}

test "vertices, centro, borde y punto exterior" {
    const a = Punto{ .x = 0, .y = 0 };
    const b = Punto{ .x = 6, .y = 0 };
    const c = Punto{ .x = 0, .y = 6 };
    try std.testing.expectEqual([3]u8{ 255, 0, 0 }, color(a, b, c, a).?);
    try std.testing.expectEqual([3]u8{ 0, 255, 0 }, color(a, b, c, b).?);
    try std.testing.expectEqual([3]u8{ 0, 0, 255 }, color(a, b, c, c).?);
    try std.testing.expectEqual([3]u8{ 85, 85, 85 }, color(a, b, c, .{ .x = 2, .y = 2 }).?);
    try std.testing.expectEqual([3]u8{ 128, 128, 0 }, color(a, b, c, .{ .x = 3, .y = 0 }).?);
    try std.testing.expect(color(a, b, c, .{ .x = 5, .y = 5 }) == null);
}

test "el orden de los vertices conserva sus pesos" {
    const a = Punto{ .x = -2, .y = 1 };
    const b = Punto{ .x = 8, .y = 2 };
    const c = Punto{ .x = 1, .y = 9 };
    const p = Punto{ .x = 2, .y = 3 };
    const original = coordenadas(a, b, c, p).?;
    const invertido = coordenadas(c, b, a, p).?;
    for (0..3) |i| try std.testing.expectApproxEqAbs(original[i], invertido[2 - i], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), original[0] + original[1] + original[2], 1e-12);
}

test "un triangulo sin area no se pinta" {
    const a = Punto{ .x = 1, .y = 1 };
    const b = Punto{ .x = 2, .y = 2 };
    const c = Punto{ .x = 3, .y = 3 };
    try std.testing.expect(color(a, b, c, a) == null);
    try std.testing.expect(color(a, a, c, b) == null);
}
