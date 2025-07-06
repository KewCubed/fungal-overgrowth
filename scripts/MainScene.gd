extends Node2D

@onready var background := $Background2
@onready var spore_particle_scene = preload("res://scenes/SporeParticle.tscn")
@onready var ui_overlay_scene = preload("res://scenes/UIOverlay.tscn")
var ui: CanvasLayer
const NOTIFICATION_WM_RESIZED = 1004

var dragging := false
var drag_origin := Vector2()
var drag_camera_anchor := Vector2()
@onready var cam := $Camera2D

func _ready():
	DisplayServer.window_set_min_size(Vector2i(960, 540))
	ui = ui_overlay_scene.instantiate()
	add_child(ui)

	# Get background size before frame starts
	var bg_size = background.texture.get_size() * background.scale
	cam.force_update_scroll()

func _notification(what):
	if what == NOTIFICATION_WM_RESIZED:
		var new_size = get_viewport().get_visible_rect().size
		print("RESIZED VIEWPORT:", new_size)

func is_mouse_over_mushroom() -> bool:
	var local_mouse = $MushroomSprite.to_local(get_global_mouse_position())
	return $MushroomSprite.get_node("Sprite2D").get_rect().has_point(local_mouse)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not is_mouse_over_mushroom():
				dragging = true
				drag_origin = get_global_mouse_position()
				drag_camera_anchor = cam.position
			else:
				dragging = false
	elif event is InputEventMouseMotion and dragging:
		var delta = drag_origin - get_global_mouse_position()
		var new_pos = drag_camera_anchor + delta
		cam.position = clamp_camera(new_pos)

func clamp_camera(pos: Vector2) -> Vector2:
	var half_viewport = get_viewport().get_visible_rect().size / 2.0
	var bg_pos = background.global_position
	var bg_size = background.size
	var bg_min = bg_pos + half_viewport
	var bg_max = bg_pos + bg_size - half_viewport

	if half_viewport.x * 2 >= bg_size.x or half_viewport.y * 2 >= bg_size.y:
		return bg_pos + bg_size / 2.0

	return pos.clamp(bg_min, bg_max)

func _process(_delta):
	if ui:
		ui.update_currency("Spores", GameManager.spores, GameManager.spores_passive)
		ui.update_currency("Nutrients", GameManager.nutrients, GameManager.nutrients_passive)
		ui.update_currency("Mycelium Mass", GameManager.mycelium_mass, GameManager.mycelium_passive)
		ui.update_currency("Mutagen", GameManager.mutagen, GameManager.mutagen_passive)
		ui.update_currency("Neural Essence", GameManager.neural_essence, GameManager.neural_passive)

func add_spores(amount: int) -> void:
	GameManager.spores += amount

func _on_mushroom_sprite_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var now = Time.get_ticks_msec() / 1000.0
		if now - GameManager.last_click_time < GameManager.click_cooldown:
			return
		GameManager.last_click_time = now
		GameManager.add_spores(1)
		spawn_spore_particle(get_global_mouse_position())
		squish_mushroom()

func squish_mushroom():
	var sprite = $MushroomSprite/Sprite2D
	sprite.scale = Vector2(0.85, 1.15)
	create_tween().tween_property(sprite, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func spawn_spore_particle(click_pos: Vector2):
	var spore = spore_particle_scene.instantiate()
	add_child(spore)
	var spread = 8
	var offset = Vector2(randf_range(-spread, spread), randf_range(-spread / 2, spread / 2))
	spore.global_position = click_pos + offset
