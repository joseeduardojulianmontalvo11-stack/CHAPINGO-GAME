extends RefCounted
## Convierte el área segura física a coordenadas del lienzo (incluye escalado).
static func rect(viewport: Viewport) -> Rect2:
	var full := viewport.get_visible_rect()
	var safe := DisplayServer.get_display_safe_area()
	if DisplayServer.get_name() == "headless" or safe.size.x <= 0 or not OS.has_feature("mobile"):
		return full.grow(-24)
	var inverse := viewport.get_screen_transform().affine_inverse()
	var local := Rect2(inverse * Vector2(safe.position), Vector2.ZERO)
	local.end = inverse * Vector2(safe.end)
	return full.intersection(local).grow(-24)
