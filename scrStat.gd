extends MarginContainer


func swapStyle(style : StyleBox):
	$items/Panel.add_stylebox_override("panel", style)


func _ready() -> void:
	$items/Panel/Label.text = " " + name
	swapStyle(Glo.defaultStylebox)

var n : String = "0"
func changeNum(num : String):
	n = num
	$items/Panel2/Label.text = num


func _on_Button_pressed() -> void:
	OS.set_clipboard(n)
	$Tween.interpolate_property($Panel, "modulate", Color.white, Color.transparent, 1, Tween.TRANS_LINEAR)
	$Tween.start()
