extends RefCounted
## Datos ampliables: cada tema tiene un id estable y opciones [texto, efecto, respuesta].
const PEOPLE := {
	"ines": {
		"name": "Inés", "place": "Patio de Honor", "position": Vector2(1790, 1180),
		"palette": [Color("cf7649"), Color("a97450"), Color("27201e")], "accessory": 0,
		"info": "Curiosa y directa. De nuevo ingreso; fotografía plantas y anota rutas para no perderse.",
		"greetings": ["¿También buscas tu salón? Mi mapa ya tiene más correcciones que mi examen de álgebra.", "¡Compañero de expedición! Hoy encontré el salón sin preguntarle a un árbol.", "¡Qué gusto verte! Te guardé una foto del jacarandá. Salió mejor que mi credencial."],
		"topics": {
			"llegada": {"title": "El primer día", "line": "Vengo de Oaxaca. Extraño mi casa, pero me emociona estudiar aquí. ¿Cómo vas?", "choices": [["También extraño mi casa. Vamos con calma.", 20, "Se agradece decirlo en voz alta. Mañana ubicamos otro edificio."], ["Me interesa conocer el campus contigo.", 15, "Trato. Tú llevas el mapa; yo pregunto si nos perdemos."], ["Eso no me interesa.", -10, "Está bien. Voy a seguir con mi recorrido."]]},
			"intereses": {"title": "Fotos y plantas", "line": "Quiero hacer un álbum de plantas del campus. Tengo doce fotos del mismo árbol. Es muy fotogénico.", "choices": [["Te ayudo a identificar las especies.", 25, "¡Sí! El álbum merece nombres mejores que árbol uno y árbol dos."], ["Puedo ayudarte con las fotografías.", 20, "Perfecto, mi dedo sale en demasiadas fotos."], ["Qué pérdida de tiempo.", -10, "Para mí sí tiene valor. Mejor cambiamos de tema."]]},
			"apoyo": {"title": "Semana de exámenes", "line": "Me da pena preguntar cuando no entiendo. ¿Y si todos ya saben?", "choices": [["Podemos estudiar y preguntar juntos.", 25, "Gracias. Formamos equipo: dos dudas hacen menos ruido que una sola."], ["Empieza con una duda pequeña.", 15, "Puedo intentar eso. Una página a la vez."], ["Si no entiendes, mejor ni preguntes.", -15, "No ayuda mucho escuchar eso. Voy a buscar a alguien del grupo."]]}
		}
	},
	"beto": {
		"name": "Beto", "place": "Comedor Central", "position": Vector2(760, 1330),
		"palette": [Color("3b86a0"), Color("dbac7e"), Color("573729")], "accessory": 1,
		"info": "Sociable y bromista. Viene de Veracruz; juega voleibol y aprende a organizar su presupuesto.",
		"greetings": ["Soy Beto. Todavía no sé todos los edificios, pero ya ubico el comedor. Hay prioridades.", "¡Qué onda, compañero! Hoy sobreviví a matemáticas sin usar los dedos. Casi.", "¡Amigo! Aquí hay lugar. La fila avanza lento, pero el chisme tiene velocidad de laboratorio."],
		"topics": {
			"llegada": {"title": "Adaptarse al campus", "line": "En mi casa siempre había alguien en la cocina. Aquí hice fila solo el primer día. Se sintió raro.", "choices": [["Mañana podemos venir juntos.", 20, "Me late. La fila con conversación pesa menos."], ["Ya irás conociendo gente.", 10, "Eso intento. Mi estrategia empieza por saludar."], ["Mejor acostúmbrate a estar solo.", -10, "Bueno, yo prefiero intentar hacer equipo."]]},
			"intereses": {"title": "Voleibol entre clases", "line": "Quiero armar una reta de voleibol. Aceptamos principiantes y gente que le tenga miedo al balón.", "choices": [["Me apunto, aunque esté aprendiendo.", 25, "¡De eso se trata! Si se cae el balón, tenemos gravedad de nuestro lado."], ["Puedo ir a animar al equipo.", 20, "También cuenta. Necesitamos porra que no se ría demasiado."], ["Qué flojera tu equipo.", -10, "Va, no es obligación. Pero tampoco hacía falta el remate."]]},
			"apoyo": {"title": "El presupuesto semanal", "line": "Mi libreta dice que me alcanza para copias o antojos. La libreta tiene una actitud muy negativa.", "choices": [["Hagamos cuentas y compartamos apuntes.", 25, "Buena idea. Mi yo del viernes te va a agradecer."], ["Aparta primero lo de las copias.", 15, "Consejo sensato. Doloroso, pero sensato."], ["Pues gasta todo y ya.", -15, "Paso. No quiero cenar el ticket de compra."]]}
		}
	},
	"luz": {
		"name": "Luz", "place": "Biblioteca Central", "position": Vector2(2460, 610),
		"palette": [Color("9e6bb1"), Color("82553e"), Color("181d22")], "accessory": 2,
		"info": "Reservada, observadora y de humor seco. De Hidalgo; le gustan la lectura, los suelos y el ajedrez.",
		"greetings": ["Hola, soy Luz. Si buscas silencio, es aquí. Si buscas enchufe, empieza la competencia.", "Hola, compañero. Encontré una mesa libre. Evento astronómico poco frecuente.", "¡Llegaste! Te aparté una silla. Ya sabes que comparto apuntes, pero mi lápiz favorito tiene abogado."],
		"topics": {
			"llegada": {"title": "Un lugar tranquilo", "line": "Después de tantas presentaciones necesito un rato de silencio. No es mala cara: es batería baja.", "choices": [["Lo entiendo. Podemos hablar sin prisa.", 20, "Gracias. No todos los silencios necesitan rescate."], ["Te saludo después, si prefieres.", 15, "Me parece bien. Gracias por preguntar."], ["Deberías ser menos rara.", -10, "Prefiero que respetes cómo soy."]]},
			"intereses": {"title": "Libros y suelos", "line": "Estoy leyendo sobre suelos. Mis amistades dicen que es un tema muy profundo. Les cobro por el chiste.", "choices": [["¿Qué te gusta de estudiar los suelos?", 25, "Que una muestra pequeña cuenta una historia enorme. Te enseño el libro si quieres."], ["Te cambio una partida de ajedrez por un resumen.", 20, "Acepto. Pero aviso que mis peones sí hicieron la tarea."], ["Eso suena aburridísimo.", -10, "No tiene que gustarte, pero podrías decirlo con más cuidado."]]},
			"apoyo": {"title": "Trabajo en equipo", "line": "En el equipo nadie responde y la entrega es mañana. El documento tiene más cursores que palabras.", "choices": [["Podemos ordenar tareas y pedir ayuda.", 25, "Eso sí sirve. Voy a escribir un plan, sin hacer todo sola."], ["Habla con tu equipo antes de desvelarte.", 15, "Sí. Dormir también debería contar como crédito."], ["Hazles todo, así acabas rápido.", -15, "No quiero acostumbrarlos ni quedarme sin dormir."]]}
		}
	}
}
const MEAL := {"title": "Compartir un rato en el comedor", "line": "¿Nos sentamos a platicar después de comer? Sin tarea de por medio, por una vez.", "choices": [["Sí, me gustaría compartir este rato.", 20, "Entre anécdotas de casa y planes de la semana, la sobremesa se pasa volando. El campus ya se siente menos ajeno."], ["Hoy prefiero comer por mi cuenta.", 0, "Sin problema. Cada quien necesita su espacio."], ["Solo si me haces toda la tarea.", -10, "Mejor no. Busco compañía, no una entrega extra."]]}
