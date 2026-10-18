# Lab 3: Triángulo baricéntrico

Triángulo con interpolación de rojo, verde y azul usando coordenadas baricéntricas. Hecho en Zig 0.16.0, sin librerías de gráficos.

## Ejecutar

Desde la carpeta del repositorio:

```powershell
zig build run
zig build test
```

El programa guarda `imagenes/triangulo1.bmp`, de 960 × 540 píxeles. La carpeta `imagenes` debe existir al ejecutarlo.

## Cálculo del color

Para cada píxel se calculan tres pesos dividiendo áreas con signo entre el área del triángulo completo. Si algún peso es negativo, el punto está afuera y queda negro. Dentro del triángulo, los pesos suman 1.

Cada peso se multiplica por 255 para obtener rojo, verde y azul. En cada vértice aparece un color puro y hacia el centro se mezclan los tres.

Los vértices se pueden cambiar en `src/main.zig`, en la lista `ejemplos`. El orden es rojo, verde y azul. El origen está arriba a la izquierda, con x hacia la derecha y y hacia abajo. El cálculo funciona en ambos sentidos de recorrido; los triángulos sin área no se pintan. Solo se dibujan los píxeles dentro del lienzo.

## Resultado

![Triángulo RGB](imagenes/triangulo1.bmp)
