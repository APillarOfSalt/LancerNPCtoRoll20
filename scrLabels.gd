extends MarginContainer

func _ready() -> void:
	swapStyle(Glo.defaultStylebox)


func swapStyle(style : StyleBox):
	$v/p.add_stylebox_override("panel", style)

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
	OS.set_clipboard(t)
	$Tween.interpolate_property($v/m/flash, "modulate", Color.white, Color.transparent, 1, Tween.TRANS_LINEAR)
	$Tween.start()


func _on_Named_pressed() -> void:
	OS.set_clipboard(nm)
	$Tween.interpolate_property($v/p/flash, "modulate", Color.white, Color.transparent, 1, Tween.TRANS_LINEAR)
	$Tween.start()


func _on_showHide_toggled(button_pressed: bool) -> void:
	$v/m.visible = !button_pressed
