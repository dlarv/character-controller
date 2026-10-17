extends RichTextLabel

@export var stamina: StaminaHandler


func _process(_delta: float) -> void:
	if not stamina: return

	var color := "RED" if stamina.is_empty else "GREEN"
	text = "[color=%s]%.1f[/color]/%.1f" % [color, stamina.stamina, stamina.max_stamina]


