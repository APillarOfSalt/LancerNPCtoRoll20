extends MenuButton

var bigDaddy : Node

func _ready() -> void:
	get_popup().connect("id_pressed", Callable(self, "_on_PopupMenu_id_pressed"))

#called when all lcp's are loaded
func lcpsLoaded(_dummy):
	get_popup().clear()
	for lcpName in Glo.config.data.keys():
		if lcpName != "theme":
			get_popup().add_check_item(lcpName)
			get_popup().set_item_checked(get_popup().item_count-1, Glo.config.data[lcpName])


func _on_PopupMenu_id_pressed(id: int) -> void:
	var checked = !get_popup().is_item_checked(id)
	get_popup().set_item_checked(id, checked)
	var named = get_popup().get_item_text(id)
	Glo.config.lcpIO(named, checked)
