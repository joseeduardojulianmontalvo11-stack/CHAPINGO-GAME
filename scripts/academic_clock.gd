extends RefCounted
## Reloj academico independiente del arbol de escena y facil de persistir.

signal changed
const WEEKDAYS := ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
const DEFAULT_MINUTE := 8 * 60
const DEFAULT_SCALE := 0.5 # minutos del juego por segundo real; 12 h duran 24 min.

var day := 1
var minute_of_day := DEFAULT_MINUTE
var minutes_per_real_second := DEFAULT_SCALE
var fraction := 0.0

func reset() -> void:
	day = 1
	minute_of_day = DEFAULT_MINUTE
	fraction = 0.0
	changed.emit()

func advance_real(delta: float) -> void:
	fraction += maxf(delta, 0.0) * minutes_per_real_second
	var whole := int(fraction)
	if whole > 0:
		fraction -= whole
		advance_minutes(whole)

func advance_minutes(value: int) -> void:
	if value <= 0:
		return
	minute_of_day += value
	while minute_of_day >= 24 * 60:
		minute_of_day -= 24 * 60
		day += 1
	changed.emit()

func sleep_to_next_day() -> void:
	day += 1
	minute_of_day = DEFAULT_MINUTE
	fraction = 0.0
	changed.emit()

func set_time(new_day: int, new_minute: int) -> void:
	day = maxi(new_day, 1)
	minute_of_day = clampi(new_minute, 0, 1439)
	fraction = 0.0
	changed.emit()

func weekday_index(for_day := day) -> int:
	return posmod(for_day - 1, WEEKDAYS.size())

func weekday_name(for_day := day) -> String:
	return WEEKDAYS[weekday_index(for_day)]

func time_text() -> String:
	return "%02d:%02d" % [minute_of_day / 60, minute_of_day % 60]

func label() -> String:
	return "%s · Día %d · %s" % [weekday_name(), day, time_text()]

func snapshot() -> Dictionary:
	return {"day": day, "minute": minute_of_day}

func restore(data: Dictionary) -> void:
	var restored_day = data.get("day", 1)
	var restored_minute = data.get("minute", DEFAULT_MINUTE)
	if not (restored_day is int or restored_day is float) or not (restored_minute is int or restored_minute is float):
		reset()
		return
	set_time(int(restored_day), int(restored_minute))
