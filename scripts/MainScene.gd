extends Node2D

@onready var SporeParticleScene = preload("res://scenes/SporeParticle.tscn")
@onready var UIOverlayScene = preload("res://scenes/UIOverlay.tscn")
var ui = null

func _ready():
	print("MainScene is running")
	ui = UIOverlayScene.instantiate()
	add_child(ui)
	
func _process(_delta):
	ui.update_currency("Spores", GameManager.spores, GameManager.spores_passive)
	ui.update_currency("Nutrients", GameManager.nutrients, GameManager.nutrients_passive)
	ui.update_currency("Mycelium Mass", GameManager.mycelium_mass, GameManager.mycelium_passive)
	ui.update_currency("Mutagen", GameManager.mutagen, GameManager.mutagen_passive)
	ui.update_currency("Neural Essence", GameManager.neural_essence, GameManager.neural_passive)

func add_spores(amount: int) -> void:
	GameManager.spores += amount


func _on_mushroom_sprite_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var time_now = Time.get_ticks_msec() / 1000.0
		if time_now - GameManager.last_click_time < GameManager.click_cooldown:
			return  # too soon — skip

		GameManager.last_click_time = time_now
		GameManager.add_spores(1)
		spawn_spore_particle(event.position)
		squish_mushroom()


func squish_mushroom():
	var mushroom_sprite = $MushroomSprite/Sprite2D
	mushroom_sprite.scale = Vector2(0.85, 1.15)

	var tween = create_tween()
	tween.tween_property(
		mushroom_sprite,
		"scale",
		Vector2(1, 1),
		0.15
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func spawn_spore_particle(click_pos: Vector2):
	var spore = SporeParticleScene.instantiate()
	add_child(spore)

	var spread = 8
	var offset = Vector2(
		randf_range(-spread, spread),
		randf_range(-spread / 2, spread / 2)
	)

	spore.global_position = click_pos + offset
