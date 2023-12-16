extends Marker2D


func _on_o_item_selected(index: int) -> void:
	var style = ""
	match index:
		0: #gms red
			style = "gms"
		1: #horus
			style = "hor"
		2: #salt
			style = "aps"
	Glo.defaultStylebox = Glo.styleboxes[style]
	get_tree().call_group("stylebox", "swapStyle", Glo.defaultStylebox)
	Glo.config.changeTheme(style)

func lcpsLoaded(dummy) -> int:
	var data = Glo.returnLCPs(true)
	var config = Glo.config.data
	for c in $p/v/lcps/v.get_children():
		if c.name != "copy" and c.name != "Title": #if its not the copy or title
			c.queue_free() #clear it
	for lcp in data:
		var nd = $p/v/lcps/v/copy.duplicate(1)
		nd.show()
		nd.get_node("h/Label1").text = lcp.name
		nd.get_node("h/Label2").text = str(lcp.version)
		var en = nd.get_node("h/Label3")
		if config[lcp.name]: #if the lcp is enabled
			nd.get_node("h/c2").button_pressed = true
			en.add_theme_color_override("font_color", Color(.25, 1, .25) )
			en.text = "Enabled"
		else: #if the lcp if disabled
			en.add_theme_color_override("font_color", Color(1, .25, .25) )
			en.text = "Disabled"
		nd.get_node("h/c").connect("pressed", deletePressed)
		nd.get_node("h/c2").connect("pressed", enabledPressed)
		$p/v/lcps/v.add_child(nd)
	#set size and location
	var widest = 0
	for c in $p/v/lcps/v.get_children():
		widest = max(c.size.x, widest)
	$p.size.x = widest + 20
	return -widest - 20

var toBeDeleted : Array

func deletePressed():
	for c in $p/v/lcps/v.get_children():
		if c.name != "copy" and c.name != "Title": #if its not the copy or title
			if c.get_node("h/c").button_pressed: #if the delete button is pressed
				c.add_theme_stylebox_override("panel", Glo.styleboxes.setDel)
				toBeDeleted.append(c.get_node("h/Label1").text)
			else: #if the delete button is not pressed
				c.add_theme_stylebox_override("panel", Glo.styleboxes.set)
				toBeDeleted.erase(c.get_node("h/Label1").text)

var toBeEnabled : Array
var toBeDisabled  : Array

func enabledPressed():
	for c in $p/v/lcps/v.get_children():
		if c.name != "copy" and c.name != "Title": #if its not the copy or title
			var en = c.get_node("h/Label3")
			if c.get_node("h/c2").button_pressed: #if the enable button is pressed
				en.add_theme_color_override("font_color", Color(.25, 1, .25) )
				en.text = "Enabled"
				toBeEnabled.append(c.get_node("h/Label1").text)
				toBeDisabled.erase(c.get_node("h/Label1").text)
			else:
				en.add_theme_color_override("font_color", Color(1, .25, .25) )
				en.text = "Disabled"
				toBeEnabled.erase(c.get_node("h/Label1").text)
				toBeDisabled.append(c.get_node("h/Label1").text)

func swapStyle(style : StyleBox):
	var sel = 0
	match style:
		Glo.styleboxes.gms : sel = 0
		Glo.styleboxes.hor : sel = 1
		Glo.styleboxes.aps : sel = 2
	$p/v/h/o.selected = sel


func _on_confirm_pressed() -> void:
	if Glo.config.changeSettings(toBeDeleted, toBeEnabled, toBeDisabled):
		pass

func _on_cancel_pressed() -> void:
	hide()
