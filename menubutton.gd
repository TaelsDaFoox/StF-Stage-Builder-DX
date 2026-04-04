extends Button


func _on_pressed() -> void:
	Global.callbuttonPressed(get_index())

func _on_mouse_entered() -> void:
	if !disabled:
		$"../../../SFX/Move".play()
