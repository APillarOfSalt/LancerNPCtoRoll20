extends MarginContainer


func swapStyle(style : StyleBox):
	$items/Panel.add_theme_stylebox_override("panel", style)


func _ready() -> void:
	$items/Panel/Label.text = " " + name
	swapStyle(Glo.defaultStylebox)

var n : String = "0"
func changeNum(num : String):
	n = num
	$items/Panel2/Label.text = num


func _on_Button_pressed() -> void:
	$Panel.modulate = Color.WHITE
	DisplayServer.clipboard_set(n)
	var tween = create_tween().set_loops(1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property($Panel, "modulate", Color.TRANSPARENT, 1)
	tween.play()
