extends CanvasLayer

var animate_panels := true # Set to false to disable slide animation
var panel_slide_time := 0.3

@onready var currency_panel := $MenuContainer/Menus/CurrencyPanel
@onready var upgrade_panel := $MenuContainer/Menus/UpgradeShopPanel
@onready var currency_button := $MenuButtons/CurrencyButton
@onready var upgrade_button := $MenuButtons/UpgradeButton
@onready var upgrade_close_button := $MenuContainer/Menus/UpgradeShopPanel/CloseButton
@onready var tween := get_tree().create_tween()

var open_panel: Control = null
var panel_state := "closed" # "closed", "opening", "open", "closing"
var queued_panel: Control = null

func _ready():
	currency_button.pressed.connect(_on_currency_button_pressed)
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	upgrade_close_button.pressed.connect(_on_upgrade_close_button_pressed)
	currency_panel.position.y = -currency_panel.size.y
	currency_panel.visible = false
	upgrade_panel.position.y = -upgrade_panel.size.y
	upgrade_panel.visible = false

func update_currency(name: String, value: int, passive: float) -> void:
	pass

func _on_currency_button_pressed():
	_request_panel(currency_panel)

func _on_upgrade_button_pressed():
	_request_panel(upgrade_panel)

func _on_upgrade_close_button_pressed():
	if open_panel == upgrade_panel:
		_request_panel(null)

func _request_panel(panel: Control):
	if panel_state in ["opening", "closing"]:
		queued_panel = panel
	else:
		_animate_panel_switch(panel)

func _animate_panel_switch(panel: Control):
	if open_panel and open_panel != panel:
		# Close current, then open new after
		panel_state = "closing"
		_set_panel_input_blocked(open_panel, true)
		_close_panel(open_panel, func():
			open_panel = null
			if panel:
				_animate_panel_switch(panel)
			else:
				panel_state = "closed"
		)
	elif open_panel == panel:
		# Close current
		panel_state = "closing"
		_set_panel_input_blocked(open_panel, true)
		_close_panel(open_panel, func():
			open_panel = null
			panel_state = "closed"
		)
	elif panel:
		# Open new
		open_panel = panel
		panel_state = "opening"
		panel.visible = true
		_set_panel_input_blocked(panel, true)
		_open_panel(panel, func():
			panel_state = "open"
			_set_panel_input_blocked(panel, false)
		)
	else:
		panel_state = "closed"

func _open_panel(panel: Control, on_done: Callable):
	if animate_panels:
		tween.kill()
		panel.position.y = -panel.size.y
		tween = create_tween()
		tween.tween_property(panel, "position:y", 5, panel_slide_time)
		tween.tween_callback(on_done)
	else:
		panel.position.y = 5
		on_done.call()

func _close_panel(panel: Control, on_done: Callable):
	if animate_panels:
		tween.kill()
		tween = create_tween()
		tween.tween_property(panel, "position:y", -panel.size.y, panel_slide_time)
		tween.tween_callback(Callable(panel, "hide"))
		tween.tween_callback(on_done)
	else:
		panel.visible = false
		on_done.call()

func _set_panel_input_blocked(panel: Control, blocked: bool):
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE if blocked else Control.MOUSE_FILTER_STOP
	for child in panel.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE if blocked else Control.MOUSE_FILTER_STOP

func _process(_delta):
	# Handle queued panel requests after animation
	if panel_state == "open" or panel_state == "closed":
		if queued_panel != null:
			var next_panel = queued_panel
			queued_panel = null
			_animate_panel_switch(next_panel)
