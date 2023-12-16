extends MarginContainer

func _ready() -> void:
	swapStyle(Glo.defaultStylebox)


func swapStyle(style : StyleBox):
	$v/p.add_theme_stylebox_override("panel", style)

var t : String
var nm : String

func changeText(txt : String):
	t = txt
	var s = "{{name="
	var startInd : int = t.find(s) + s.length()
	var read = t.substr(startInd,1)
	nm = ""
	while read != "}" and read != "(":
		nm += read
		startInd +=1
		read = t.substr(startInd,1)
	$v/p/h/Label.text = " " + nm + " "
	$v/m/Panel/label.text = txt

func _on_Button_pressed() -> void:
	$v/m/flash.modulate = Color.WHITE
	DisplayServer.clipboard_set(t)
	var tween = create_tween().set_loops(1)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($v/m/flash, "modulate", Color.TRANSPARENT, 1.0)
	tween.play()

func _on_Named_pressed() -> void:
	$v/p/flash.modulate = Color.WHITE
	DisplayServer.clipboard_set(nm)
	var tween = create_tween().set_loops(1)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($v/p/flash, "modulate", Color.TRANSPARENT, 1.0)
	tween.play()

func _on_showHide_toggled(button_pressed: bool) -> void:
	$v/m.visible = !button_pressed
