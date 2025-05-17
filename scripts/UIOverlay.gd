extends CanvasLayer

func update_currency(name: String, value: int, passive: float) -> void:
	var container = $MarginContainer/Control/VBoxContainer.get_node(name)
	container.get_node("Value").text = str(value)
	container.get_node("PassiveValue").text = "(+%.1f/s)" % passive
