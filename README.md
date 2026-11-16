# CHAPINGO: VIDA UNIVERSITARIA — V0.6

V0.6 incorpora una primera vida social modular: tres compañeros, conversaciones con decisiones, amistades y dos misiones opcionales. Conserva el campus, sus cinco estudiantes ambientales y el sistema académico de V0.5.3.

## Vida social V0.6

| Compañero | Ubicación habitual | Personalidad e intereses |
| --- | --- | --- |
| Inés | Patio de Honor | Curiosa y directa; fotografía plantas y aprende las rutas del campus. |
| Beto | Junto al Comedor Central | Sociable y bromista; voleibol, convivencia y presupuesto estudiantil. |
| Luz | Frente a Biblioteca Central | Reservada, observadora y de humor seco; lectura, suelos y ajedrez. |

Acércate a un compañero y pulsa **E** o **Acción**. Elige un tema y una respuesta con mouse, toque o teclado (**Tab**, flechas y **Enter/Espacio**). Las respuestas tienen reacciones propias; pueden aumentar o reducir la afinidad independiente de cada persona, limitada a 0–100. Los saludos cambian con el nivel: **Conocido (0–29)**, **Compañero (30–59)** y **Amigo (60–100)**. Cada tema registra una decisión importante y modifica la afinidad una sola vez por partida. Al repetirlo se recuerda la respuesta anterior sin volver a sumar puntos.

**Social (R)**, situado debajo de la barra superior sin ampliar su fila, abre las relaciones, ubicaciones, intereses, afinidad y nivel. Las personas aún no saludadas aparecen como **Por conocer**. **Esc**, **R** o el botón fijo **Cerrar** terminan la conversación; **Volver a los temas** permite seguir charlando. La conversación pausa el reloj y el movimiento. Los botones del HUD dejan de aceptar foco mientras hay un modal; al cerrar recuperan su funcionamiento. Se conserva `MOUSE_FILTER_IGNORE` en el Control raíz del HUD.

Las misiones secundarias se descubren al saludar y aparecen en el diario existente:

- **Un campus con nombres:** conoce a dos compañeros distintos. Repetir saludos a la misma persona no completa el objetivo.
- **Un lugar en la mesa:** alcanza 30 de afinidad con Beto y elige compartir un rato junto al comedor. Posponer la invitación permite retomarla después. Repetir sobremesas no concede afinidad adicional.

Las misiones sociales son opcionales y no bloquean las clases, misiones anteriores ni la exploración. Los compañeros ocupan puntos transitables existentes, sin añadir colisiones. Su ubicación es fija en esta primera versión; no siguen al protagonista ni aparecen en las viviendas.

El guardado añade un campo `social` con afinidades, decisiones y sobremesas, conservando `version: 1`, el perfil, las misiones y los datos académicos. Las partidas V0.2–V0.5.3 sin ese campo reciben relaciones vacías al cargar; la carga no reescribe el archivo. El progreso se guarda al conocer a alguien y al decidir, además de los controles de guardado existentes.

Para ampliar el sistema, añade personajes y temas con identificadores estables en `scripts/social_catalog.gd`. `social_state.gd` valida y serializa el estado; `social_manager.gd` conecta interacciones y eventos de misiones; `social_student.gd` reutiliza el dibujo de estudiantes; `social_ui.gd` presenta texto y opciones en un área vertical con cierre y navegación fijos.

## Mejoras académicas conservadas


V0.5.3 separa el panel académico en navegación y título, preguntas con desplazamiento vertical y un pie fijo con retroalimentación y **Entregar actividad**. El botón permanece accesible al recorrer las preguntas, con mouse o teclado (Tab/Enter). La validación enumera las preguntas pendientes y enfoca la primera; la entrega conserva calificación, historial y guardado, sin duplicar actividades. Las listas mantienen su ancho y el foco de teclado desplaza la pregunta a la vista. Se conserva la corrección `MOUSE_FILTER_IGNORE` del HUD y el formato de partidas existentes.

V0.5.2 corrige el bloqueo de clics en la interfaz académica: el Control raíz transparente del HUD ignora el mouse y sus hijos interactivos conservan sus filtros. Las tres listas de respuestas, la entrega y los botones del HUD se verifican enviando eventos de mouse al viewport.

V0.5.1 pule la interfaz y el flujo académico de V0.5 sin modificar los sistemas ni las coordenadas principales del campus V0.4.

Simulador universitario 2D de vista superior inspirado en la Universidad Autónoma Chapingo. El campus es una representación original construida con primitivas de Godot; no utiliza el mapa institucional como fondo ni presenta horarios oficiales de la universidad.

## Primera jornada académica

V0.5 incorpora una base académica jugable sin limitar la exploración libre:

- Reloj interno con hora, día y día de la semana.
- Escala predeterminada de 0.5 minutos del juego por segundo real: una jornada de 12 horas dura aproximadamente 24 minutos.
- Botánica, Matemáticas e Introducción a los Suelos, cada una con identificador, profesor, ubicación y sesiones semanales ficticias.
- Ventanas amplias para llegar a clase, con registro separado de asistencia puntual, llegada tarde y falta.
- Prevención de asistencia duplicada por sesión.
- Actividad reutilizable de tres preguntas por materia y calificación de 0 a 10.
- Una actividad ya evaluada no puede repetirse para generar calificaciones ilimitadas.
- Panel académico con resumen, próxima clase, horario e historial de asistencias y calificaciones.
- Descanso en la vivienda para avanzar al siguiente día a las 08:00.

El reloj se pausa durante diálogos, diario, ayuda, panel académico y actividades de lectura. Los cinco estudiantes ambientales continúan recorriendo sus rutas normalmente mientras el reloj avanza.

Para asistir, consulta **Académico (H)**, dirígete a la entrada existente de AULAS durante una sesión y pulsa **E** o **Acción**. Faltar o llegar tarde sólo se registra: nunca bloquea el campus ni termina la partida.

## Interfaz V0.5.1

La barra superior reúne en una sola fila:

- Guardar.
- Guardar y menú.
- Nombre del jugador.
- Día y hora.
- Académico (H).
- Diario (J).
- Ayuda.

Las instrucciones permanentes se sustituyeron por un panel **Ayuda** accesible. En V0.5.1 el panel usa un título y cierre separados, ancho de lectura estable, ajuste por palabras y desplazamiento vertical dentro del área segura. La versión se define una sola vez en `scripts/app_info.gd` y se reutiliza en menú e interfaz. Los botones principales mantienen al menos 48 unidades de alto.

En la entrada de AULAS, el aviso indica si no hay clase y muestra la próxima materia y hora. Si hay clase, anuncia materia y hora antes de asistir. La actividad exige seleccionar una respuesta para cada una de sus tres preguntas, avisa si falta alguna y, al entregarse, muestra la calificación junto con el historial académico.

El joystick y los botones **Acción** y **Cerrar** se conservan. En escritorio, **Ctrl + Shift + M** muestra u oculta la simulación táctil.

## Campus y funciones conservadas

El campus V0.4 mantiene sus dimensiones de 3200×2200, coordenadas, colisiones, caminos y edificios: Rectoría, Biblioteca Central, Comedor Central, Patio de Honor, Auditorio Álvaro Carrillo, Preparatoria Agrícola, dormitorios, La Meche, jardines y áreas deportivas.

También se conservan:

- Creador de personaje y elección de vivienda.
- Interiores del internado y vivienda externa.
- Movimiento, cámara y cinco estudiantes ambientales.
- Marisol y sus diálogos.
- Misiones **¿Dónde está mi salón?** y **El primer desayuno**.
- Diario de misiones.
- Guardado y carga.
- Controles WASD, flechas, teclado, mouse y tacto.

## Controles

- **WASD o flechas:** caminar.
- **E:** interactuar, asistir a clase o avanzar diálogo.
- **Esc:** cerrar diálogo o panel modal.
- **J:** abrir/cerrar diario de misiones.
- **H:** abrir/cerrar panel académico.
- **R / Social:** consultar relaciones o cerrar una conversación social.
- **Ctrl + Shift + M:** simular controles táctiles en escritorio.

## Guardado y compatibilidad

El archivo `user://partida.json` conserva perfil, vivienda, ubicación, posición, misiones, día, hora, asistencias, actividades, calificaciones y relaciones sociales. El formato sigue aceptando partidas de V0.2, V0.2.1, V0.3 y V0.4: si faltan campos académicos, se inicializan sin borrar los sistemas anteriores.

Al cargar una posición antigua del campus se comprueba que sea transitable. Si quedó dentro de un edificio, árbol, banca, luminaria o límite tras la ampliación V0.4, el estudiante reaparece en un punto central seguro sin perder progreso.

En Windows, el guardado normal corresponde a `%APPDATA%/Godot/app_userdata/CHAPINGO- VIDA UNIVERSITARIA/`.

## Arquitectura

- `scripts/app_info.gd`: nombre y versión centralizados.
- `scripts/academic_clock.gd`: reloj, calendario, escala y avance de día.
- `scripts/academic_schedule.gd`: materias, profesores, sesiones y preguntas.
- `scripts/academics.gd`: asistencias, faltas, actividades, calificaciones y persistencia.
- `scripts/academic_manager.gd`: integración del sistema académico con el mundo.
- `scripts/academic_ui.gd`: resumen, horario, actividad e historial.
- `scripts/game_hud.gd`: barra superior y ayuda accesible.
- `scripts/session.gd`: perfil, misiones, datos académicos, relaciones y compatibilidad de guardado.
- `scripts/social_catalog.gd`, `social_state.gd`, `social_manager.gd`, `social_student.gd`, `social_ui.gd`: datos, estado, integración, compañeros e interfaz social.
- `maps/campus.gd`: campus V0.4 y validación de posiciones transitables.
- `scripts/campus_story.gd`: Marisol, comedor, aulas y diario de misiones.

Los edificios, árboles y estudiantes ambientales siguen encapsulados en componentes reutilizables. El proyecto conserva GDScript, orientación horizontal y el renderizador **GL Compatibility**.

## Abrir y ejecutar

Instala Godot 4.x estándar (no .NET), importa `project.godot` y pulsa **F5**. El desarrollo y las pruebas automatizadas se realizaron con Godot 4.6.3. No se requieren paquetes, servicios, claves ni recursos externos.

## Pruebas

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/smoke.gd
godot --headless --path . --script tests/v02.gd
godot --headless --path . --script tests/quests.gd
godot --headless --path . --script tests/mobile.gd
godot --headless --path . --script tests/v04.gd
godot --headless --path . --script tests/v05.gd
godot --headless --path . --script tests/v051.gd
godot --headless --path . --script tests/v052.gd
godot --headless --path . --script tests/v053.gd
godot --headless --path . --script tests/v06.gd
godot --headless --path . --quit-after 120
```

`tests/v05.gd` verifica la base académica. `tests/v051.gd` añade regresiones para apertura y ancho legible de Ayuda, área segura, separación de letreros, mensajes dentro y fuera de horario, selección obligatoria de tres respuestas, entrega, calificación, historial y persistencia. Las suites anteriores continúan comprobando movimiento, colisiones, cámara, viviendas, misiones, diario, guardado y simulación táctil.

`tests/v052.gd` inicia una partida, fija lunes día 15 a las 09:05, entra a AULAS con E y usa eventos GUI de mouse para abrir las tres listas, seleccionar respuestas y entregar Botánica. Comprueba nota, historial, persistencia y clics de los botones del HUD y cierre de Ayuda. Es una prueba automatizada headless de enrutamiento GUI, no una revisión visual manual ni una prueba con mouse físico.


`tests/v053.gd` comprueba 1152×720, 960×540, 640×360 y 844×390 con eventos GUI: selección de las tres respuestas, rueda, arrastre de barra vertical, gesto pan sintético, acceso completo a la última respuesta, pie sin superposición, botón fijo, validación de preguntas pendientes, entrega con mouse y Tab/Enter, resultado, historial, prevención de duplicados y persistencia tras cargar. Incluye las tres materias con mensajes de asistencia en formato compacto. Las ocho suites anteriores también pasan con Godot 4.6.3; las expectativas de `v05.gd` comprueban ahora V0.6.

Se revisaron visualmente capturas renderizadas por Godot en Linux en los cuatro tamaños. El scroll táctil conserva el comportamiento nativo de `ScrollContainer`, con propagación de eventos desde las listas y etiquetas que ignoran el mouse. El gesto pan automatizado no equivale a arrastrar un dedo en un teléfono: quedan pendientes la prueba física en móvil y la confirmación manual en Windows.


`tests/v06.gd` comprueba los tres compañeros y sus puntos transitables, apariencia, interacción E, ramas de conversación, selección por teclado y mouse, afinidades independientes, disminuciones, límites, umbrales, saludos según nivel, antirrepetición antes y después de cargar, misiones y diario, persistencia conjunta con una nota académica y carga sin campo social. También verifica Acción táctil simulada, liberación del joystick, cierre GUI y restauración de controles, protección de modales y distribución en 1152×720, 960×540, 640×360 y 844×390, incluida la última opción de conversación y los botones fijos.

V0.6: las diez suites pasan con Godot 4.6.3. En modo headless se comprueba el cierre con mouse porque ese controlador no emula el toque del sistema a mouse. La misma suite también pasa con renderizado Linux y cierre mediante `InputEventScreenTouch` sintético. Se revisaron capturas del campus, conversaciones, resultados y relaciones en los cuatro tamaños. No se realizaron pruebas físicas en Windows, Android ni iOS: quedan pendientes la respuesta del teclado/mouse físicos, el toque y arrastre con un dedo real y las áreas seguras de dispositivos reales.
