# CHAPINGO: VIDA UNIVERSITARIA — V0.1

Primera base jugable de un simulador universitario 2D inspirado en Chapingo, México. Mapa provisional original, sin pretensión de representar fielmente el campus real.

## Abrir y ejecutar en Windows

1. Instala **Godot 4.x estándar** (GDScript; no necesitas la versión .NET). Validado con Godot 4.6.3.
2. Descarga o clona este repositorio y abre Godot.
3. Selecciona **Importar**, elige `project.godot` y pulsa **Importar y editar**.
4. Pulsa **F6** para ejecutar la escena abierta o **F5** para ejecutar el juego. La escena principal ya está configurada.

No se necesitan paquetes, servicios, claves ni recursos externos.

## Controles

- **WASD o flechas**: caminar. Las diagonales mantienen la misma velocidad.
- **E**: conversar con Marisol cuando aparezca el indicador; avanzar el diálogo.
- **Esc**: cerrar el diálogo. El movimiento queda detenido durante la conversación.

Explora los caminos, jardines, comedor, biblioteca y aulas. Los edificios, jardines elevados, troncos, NPC y límites del mapa tienen colisión. La cámara sigue al estudiante y respeta los límites del campus.

## Organización

- `scenes/main.tscn`: escena principal lista para ejecutar.
- `scripts/main.gd`: creación del mundo, entrada e interacción por proximidad.
- `scripts/student.gd`: movimiento y gráfico provisional del protagonista.
- `scripts/npc.gd`: representación y conversación de Marisol.
- `scripts/dialogue_ui.gd`: interfaz y ventana de diálogo.
- `characters/`: escenas reutilizables del estudiante y NPC.
- `maps/campus.gd`: mapa, gráficos y obstáculos.
- `resources/`: espacio para futuros recursos originales.
- `tests/smoke.gd`: prueba funcional sin interfaz gráfica.

## Comprobación desde terminal

Con el ejecutable de Godot en PATH (en Windows puede llamarse `Godot_v4.6.3-stable_win64_console.exe`):

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/smoke.gd
godot --headless --path . --quit-after 120
```

La prueba verifica carga, movimiento, colisiones, proximidad, conversación y recuperación del movimiento. La revisión visual e interacción manual en Windows quedan pendientes si solo se dispone de Linux headless.

## Alcance

Los gráficos se dibujan con primitivas originales y la fuente integrada del motor. No hay creación de personaje, interiores, audio, guardado, horarios, calificaciones ni misiones todavía. No hay errores funcionales conocidos tras las comprobaciones automatizadas; los recursos son deliberadamente provisionales.
