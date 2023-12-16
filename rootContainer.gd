extends MarginContainer

func _ready():
	get_tree().get_root().size_changed.connect(windowResized)
	windowResized()

func windowResized():
	size = DisplayServer.window_get_size()
	if $loader.visible:
		$loader.resizePopup()

func extHide() -> void:
	$loader.hideMe()
	$loader/fileDialog.hide()


func _on_settings_pressed() -> void:
	if $settings.visible:
		$settings.hide()
	else:
		var xy = $textAssembly/uiHandler/h/settings.global_position
		xy += $textAssembly/uiHandler/h/settings.size
		$settings.position = xy
		$settings.get_node("p").position.x = $settings.lcpsLoaded(Glo.returnLCPs(true))
		$settings.show()
