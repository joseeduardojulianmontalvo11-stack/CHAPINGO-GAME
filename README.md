# CHAPINGO: VIDA UNIVERSITARIA — V0.3

## Primeras misiones

La exploración sigue siendo libre. Hablar con Marisol activa **¿Dónde está mi salón?** una sola vez. Busca la entrada marcada bajo AULAS, al noreste; entrar en la zona completa la misión y muestra una bienvenida. No necesitas interactuar con una puerta ni entrar al edificio.

Para **El primer desayuno**, consulta con E o Acción el **Aviso** del comedor (izquierda de su entrada); luego consulta el **Menú** a su derecha. Es opcional y puede estar activa junto con la principal. No hay inventario, economía ni alimentación.

**J** o el botón **Diario (J)** abre y cierra el diario. El botón Cerrar del diario también permite usarlo con tacto. Agrupa principales activas, secundarias activas y completadas con sus objetivos y consecuencias. Se puede desplazar; al cerrarlo vuelve el movimiento.

El progreso de misiones se guarda al actualizarse y con los controles de guardado existentes. Los guardados V0.2/V0.2.1 sin el campo opcional `quests` se leen como partidas sin misiones iniciadas, sin reescribir el archivo durante la lectura. Mantienen personaje, vivienda y posición. Guarda antes de cerrar para conservar la última posición.

Arquitectura: `scripts/quests.gd` define misiones, estados, objetivos con identificadores estables y eventos; `scripts/campus_story.gd` conecta interacciones y zonas del mapa; `scripts/quest_journal.gd` presenta el diario. Las futuras misiones pueden usar nuevos datos y eventos, incluyendo varios objetivos ordenados.

Prueba adicional: `godot --headless --path . --script tests/quests.gd`. Usa `prueba-quests.json`, separado del guardado del jugador. Las validaciones automatizadas no sustituyen pruebas visuales o físicas en Windows/Android/iOS.

## Preparación para teléfonos

Un solo proyecto GDScript con renderizador Compatibility. Orientación horizontal, lienzo expandible, márgenes que consultan el área segura del dispositivo, creador desplazable y botones de al menos 48 unidades. El diálogo queda por encima de los controles inferiores.

En móviles se muestran automáticamente un joystick izquierdo y los botones **Acción** (interactuar o avanzar diálogo) y **Cerrar**. Guardar y Guardar y menú siguen accesibles en la parte superior. Los menús utilizan la entrada táctil estándar de Godot. Cada dedo tiene seguimiento independiente: se puede mantener el joystick y pulsar Acción con otro dedo. Perder el foco o cambiar el tamaño libera el joystick.

En Windows pulsa **Ctrl + Shift + M** durante la partida para mostrar u ocultar los controles y arrastra el joystick con el mouse. También puedes ejecutar `godot --path . -- --touch-test`. El mouse simula un dedo; la simultaneidad de dedos se verifica mediante eventos sintéticos en `tests/mobile.gd`. WASD, flechas, E y Esc siguen disponibles.

Prueba automatizada adicional: `godot --headless --path . --script tests/mobile.gd`. Las pruebas usan archivos separados de la partida real.

No se ha validado en dispositivos Android o iOS. Quedan pendientes pruebas físicas de multitáctil, teclado virtual, áreas seguras y legibilidad, así como rendimiento y ciclo de suspensión en ambos sistemas. Para exportar harán falta las plantillas de Godot, un preset y SDK/JDK para Android; para iOS, macOS con Xcode, preset, firma y aprovisionamiento de Apple. No se han generado APK ni aplicaciones iOS. La orientación vertical no es el objetivo de esta versión.

## Nueva partida y guardado

F5 abre el menú principal. **Nueva partida** permite elegir nombre (vacío usa «Estudiante»), tres camisas, cuatro colores de cabello, cuatro tonos de piel y vivienda, con vista previa. Comenzar reemplaza el guardado anterior.

Cada vivienda tiene un interior propio con cama, escritorio y colisiones. Acércate a la puerta amarilla y pulsa **E** para salir. En el campus, el letrero «Tu vivienda · E» al oeste de Marisol permite regresar a la vivienda elegida.

**Guardar** conserva nombre, apariencia, vivienda, ubicación y posición. **Guardar y menú** permite volver al menú; **Continuar** recupera una partida válida. También se guarda al comenzar y cambiar de ubicación. Cerrar la ventana sin guardar pierde el movimiento posterior al último guardado.

El archivo es `user://partida.json`; en Windows está en `%APPDATA%/Godot/app_userdata/CHAPINGO- VIDA UNIVERSITARIA/`. No se incorpora a Git. Solo hay una ranura de guardado; una partida inválida deshabilita Continuar.

Nuevos componentes: `scenes/menu.tscn`, `scripts/menu.gd` (menú y creador), `scripts/session.gd` (autoload de datos y persistencia), `maps/room.gd` (interior reutilizable), `tests/v02.gd` (creación, viviendas, transiciones y guardado). El campus sigue en `scenes/main.tscn`.

Ejecuta también `godot --headless --path . --script tests/v02.gd`. Esta prueba usa `prueba-v02.json`, separado de la partida del jugador.

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

Los gráficos se dibujan con primitivas originales y la fuente integrada del motor. No hay audio, horarios ni calificaciones todavía. Los recursos son deliberadamente provisionales. La revisión visual manual en Windows sigue pendiente.
