extends Node

var spores: int = 0
var mycelium_mass: int = 0
var nutrients: int = 0
var mutagen: int = 0
var neural_essence: int = 0

var click_cooldown := 0.5  # seconds
var last_click_time := 0.0

var spores_passive := 0.0
var mycelium_passive := 0.0
var nutrients_passive := 0.0
var mutagen_passive := 0.0
var neural_passive := 0.0

func add_spores(amount: int) -> void:
	spores += amount
