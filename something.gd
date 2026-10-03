extends Node2D

var speed = 300
var direction = Vector2(1,0)
var screen_size = Vector2()
var window_size = Vector2(200,200)

@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D
@onready var typing_timer = $TypingTimer

var is_dragging = false
var drag_offset = Vector2()
var idle_timer = 0.0
var is_idling = false
var is_typing = false

func _on_area_input(viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			# Calculate where the mouse is relative to the top-left of the window
			drag_offset = mouse_pos - win_pos
		else:
			is_dragging = false

func maybe_idle():
	if randf() < 0.03:
		is_idling = true
		# FIX: Changed '-' to '=' so the timer actually gets assigned a value
		idle_timer = randf_range(1.0, 3.0) 
		var r = randi() % 3
		if r == 0:
			animated_sprite.play("Idle")
			speed = 0

func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size())
	animated_sprite.play("Walk")
	area.input_event.connect(_on_area_input)
	typing_timer.timeout.connect(_on_typing_stopped)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		print("Key detected: ", OS.get_keycode_string(event.key_label))
		is_typing = true
		if animated_sprite.animation != ("Typing"):
			animated_sprite.play("Typing")
			typing_timer.start()
				
	
func _on_typing_stopped() -> void:
	is_typing = false
	animated_sprite.play("Walk")

			
func _physics_process(delta: float) -> void:
	if is_dragging:
		# FIX: Get the current global screen mouse position
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		# FIX: Subtract the initial offset so the window follows the mouse properly
		var target_win_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2i(target_win_pos))
		return
		
	if is_typing:
		return
		
		
		
	if is_idling:
		idle_timer -= delta
		if idle_timer <= 0:
			is_idling = false
			speed = 300
			animated_sprite.play("Walk")
		return
		
		
		

	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction * speed * delta
	
	window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y, 0, screen_size.y - window_size.y)
	
	DisplayServer.window_set_position(Vector2i(window_position))
	
	if window_position.x <= 0 or window_position.x >= screen_size.x - window_size.x:
		direction.x *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h
		maybe_idle()
		
	if window_position.y <= 0 or window_position.y >= screen_size.y - window_size.y :
		direction.y *= -1
		maybe_idle()
		
		_check_windows_global_keys()
		
func _check_windows_globa_keys() -> void:
	if not OS.has_feature("windows"):
		return
		
	var keys_to_check = [0x20, 0x0D]
	for k in range(0x41, 0x5B)
	keys_to_check.append(k)
	
	
	for vk in keys_to_check:
		if Input.is_physical_key_pressed(vk) or win_key_down(vk):
			if not is_typing:
				is_typing = true
				if animated_sprite.animation != "Typing"
					animated_sprite.play("Typing")
					
				typing_timer.start()
				break
				
func _win_key_down(virtual_key: int) -> bool:
	return false
				
					
