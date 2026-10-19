const std = @import("std");
const triangulo = @import("triangulo.zig");
const Punto = triangulo.Punto;

extern "c" fn fopen([*:0]const u8, [*:0]const u8) ?*anyopaque;
extern "c" fn fwrite([*]const u8, usize, usize, *anyopaque) usize;
extern "c" fn fclose(*anyopaque) c_int;

const ancho = 960;
const alto = 540;
const fila = (ancho * 3 + 3) & ~@as(usize, 3);

fn guardar(ruta: [:0]const u8, vertices: [3]Punto) !void {
    const archivo = fopen(ruta, "wb") orelse return error.NoSePudoAbrir;
    var cerrado = false;
    defer if (!cerrado) {
        _ = fclose(archivo);
    };
    var cabecera = [_]u8{0} ** 54;
    cabecera[0..2].* = "BM".*;
    std.mem.writeInt(u32, cabecera[2..6], 54 + fila * alto, .little);
    std.mem.writeInt(u32, cabecera[10..14], 54, .little);
    std.mem.writeInt(u32, cabecera[14..18], 40, .little);
    std.mem.writeInt(i32, cabecera[18..22], ancho, .little);
    std.mem.writeInt(i32, cabecera[22..26], alto, .little);
    std.mem.writeInt(u16, cabecera[26..28], 1, .little);
    std.mem.writeInt(u16, cabecera[28..30], 24, .little);
    std.mem.writeInt(u32, cabecera[34..38], fila * alto, .little);
    if (fwrite(&cabecera, 1, cabecera.len, archivo) != cabecera.len) return error.NoSePudoEscribir;

    // El BMP guarda primero la fila de abajo.
    var y: usize = alto;
    while (y > 0) {
        y -= 1;
        var pixeles = [_]u8{0} ** fila;
        for (0..ancho) |x| {
            const p = Punto{ .x = @floatFromInt(x), .y = @floatFromInt(y) };
            if (triangulo.color(vertices[0], vertices[1], vertices[2], p)) |rgb| {
                pixeles[x * 3 ..][0..3].* = .{ rgb[2], rgb[1], rgb[0] };
            }
        }
        if (fwrite(&pixeles, 1, pixeles.len, archivo) != pixeles.len) return error.NoSePudoEscribir;
    }
    const resultado = fclose(archivo);
    cerrado = true;
    if (resultado != 0) return error.NoSePudoEscribir;
}

pub fn main() !void {
    // Cada punto corresponde a rojo, verde y azul, en ese orden.
    const ejemplos = [3][3]Punto{
        .{ .{ .x = 30, .y = 510 }, .{ .x = 480, .y = 25 }, .{ .x = 930, .y = 510 } },
        .{ .{ .x = 240, .y = 510 }, .{ .x = 480, .y = 25 }, .{ .x = 930, .y = 510 } },
        .{ .{ .x = 25, .y = 25 }, .{ .x = 480, .y = 515 }, .{ .x = 210, .y = 25 } },
    };
    const rutas = [_][:0]const u8{ "imagenes/triangulo1.bmp", "imagenes/triangulo2.bmp", "imagenes/triangulo3.bmp" };
    for (ejemplos, rutas) |vertices, ruta| {
        try guardar(ruta, vertices);
        std.debug.print("Imagen guardada: {s}\n", .{ruta});
    }
}

test {
    _ = @import("triangulo.zig");
}
