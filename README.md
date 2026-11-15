# CHAPINGO: VIDA UNIVERSITARIA — V0.4

Simulador universitario 2D de vista superior inspirado en la Universidad Autónoma Chapingo. El campus es una representación original construida con primitivas de Godot; no utiliza el mapa institucional como fondo ni intenta reproducirlo a escala.

## Campus V0.4

El exterior creció de 1800×1200 a 3200×2200. Una red de caminos conecta la zona central y el Patio de Honor con:

- Rectoría.
- Biblioteca Central.
- Comedor Central.
- Auditorio Álvaro Carrillo.
- Preparatoria Agrícola y su acceso a aulas.
- Dormitorios.
- La Meche.
- Jardines y áreas deportivas.

Los edificios tienen paletas y fachadas diferenciadas, techos con aleros, puertas, ventanas, letreros y detalles propios. El campus incorpora árboles de copa variable, jardines con flores, bancas, luminarias, señalización, canchas y caminos texturizados. Edificios, troncos, bancas, luminarias y límites comparten geometría coherente con sus colisiones.

Cinco estudiantes secundarios recorren rutas cortas con apariencias variadas. Son elementos ambientales sin cuerpo de colisión para no bloquear al protagonista ni interferir con las misiones.

La cámara, el punto inicial, Marisol, el acceso a vivienda y las zonas de aulas/comedor se actualizaron para el mapa ampliado. Los interiores y las partidas V0.3 siguen usando el mismo formato de guardado.

## Funciones conservadas

- Creador de personaje con nombre, apariencia, cabello y tono de piel.
- Elección entre internado y vivienda externa, con interiores separados.
- Movimiento con velocidad diagonal normalizada y cámara limitada al mapa.
- NPC Marisol y diálogo en español.
- Misión principal **¿Dónde está mi salón?**.
- Misión secundaria **El primer desayuno**.
- Diario de misiones con estados, objetivos y consecuencias.
- Guardado/carga de perfil, vivienda, ubicación, posición y misiones.
- Joystick y controles táctiles; simulación en escritorio con **Ctrl + Shift + M**.

Hablar con Marisol inicia la misión principal. Cruza el Patio de Honor hacia Preparatoria Agrícola y entra en la zona marcada bajo AULAS. Para la misión del comedor, consulta primero el Aviso y después el Menú junto al acceso del Comedor Central. **J** o **Diario (J)** abre el diario.

## Controles

- **WASD o flechas:** caminar.
- **E:** interactuar, conversar o avanzar diálogo.
- **Esc:** cerrar diálogo.
- **J:** abrir/cerrar el diario.
- **Ctrl + Shift + M:** mostrar u ocultar la simulación de controles táctiles.

En móviles se muestran automáticamente un joystick izquierdo y los botones **Acción** y **Cerrar**. Cada dedo se procesa de forma independiente y perder el foco libera el joystick. Los márgenes se adaptan al área segura y los blancos táctiles principales miden al menos 48 unidades.

## Arquitectura

- `maps/campus.gd`: datos, distribución, caminos, mobiliario y comprobaciones transitables del campus.
- `scripts/campus_building.gd`: componente reutilizable de edificio; dibujo y colisión parten de la misma huella.
- `scripts/campus_tree.gd`: árbol reutilizable con copa variable y colisión en el tronco.
- `scripts/ambient_student.gd`: apariencia y rutas de estudiantes secundarios sin bloqueo.
- `scripts/main.gd`: ciclo del mundo, ubicaciones, cámara, personas e interacción.
- `scripts/campus_story.gd`: zonas e interacciones de las misiones del exterior.
- `scripts/quests.gd` y `scripts/quest_journal.gd`: datos, progreso y diario de misiones.
- `maps/room.gd`: interior reutilizable para internado y vivienda externa.
- `scripts/session.gd`: perfil y persistencia.
- `scripts/touch_controls.gd`: joystick, botones táctiles y simulación en escritorio.

El proyecto conserva GDScript y el renderizador **GL Compatibility**, con orientación horizontal y sin dependencias externas.

## Abrir y ejecutar

Instala Godot 4.x estándar (no .NET), importa `project.godot` y pulsa **F5**. Validado automáticamente con Godot 4.6.3. No se requieren paquetes, servicios, claves ni recursos externos.

El guardado normal está en `user://partida.json`; en Windows corresponde a `%APPDATA%/Godot/app_userdata/CHAPINGO- VIDA UNIVERSITARIA/`. Hay una ranura. **Guardar** conserva el estado actual y **Guardar y menú** vuelve al menú principal.

## Pruebas

Desde la raíz del proyecto:

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/smoke.gd
godot --headless --path . --script tests/v02.gd
godot --headless --path . --script tests/quests.gd
godot --headless --path . --script tests/mobile.gd
godot --headless --path . --script tests/v04.gd
godot --headless --path . --quit-after 120
```

La suite cubre carga, movimiento, cámara, dimensiones, colisiones, límites, rutas transitables, spawn, edificios, estudiantes ambientales, Marisol, ambas misiones, comedor, aulas, diario, viviendas, controles táctiles y guardado/carga.

Estas comprobaciones se ejecutan en modo headless. En el entorno de desarrollo de V0.4 el escritorio compartido no estuvo disponible, por lo que queda pendiente una revisión visual manual del mapa y una prueba física en Windows, Android e iOS. También siguen pendientes la validación real de multitáctil, áreas seguras, rendimiento, suspensión y los presets/SDK de exportación móvil.
